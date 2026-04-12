import { Component } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { Router, RouterLink } from '@angular/router';
import { AuthService } from '../../services/auth';
import { VehiculosService } from '../../services/vehiculos';
import { HttpClient } from '@angular/common/http';

@Component({
  selector: 'app-registro',
  standalone: true,
  imports: [CommonModule, FormsModule, RouterLink],
  templateUrl: './registro.html',
  styleUrl: './registro.css'
})
export class RegistroComponent {

  tipoUsuario: string = '';
  paso: number = 1;

  conductor = {
    nombre: '',
    apellido: '',
    email: '',
    telefono: '',
    contrasena: '',
    confirmar_contrasena: ''
  };

  vehiculo = {
    marca: '',
    modelo: '',
    anio: null,
    placa: '',
    color: ''
  };

  error: string = '';
  exito: string = '';
  cargando: boolean = false;
  mostrarContrasena: boolean = false;

  constructor(
    private authService: AuthService,
    private vehiculosService: VehiculosService,
    private http: HttpClient,
    private router: Router
  ) {}

  seleccionarTipo(tipo: string): void {
    this.tipoUsuario = tipo;
    this.paso = 2;
  }

  toggleContrasena(): void {
    this.mostrarContrasena = !this.mostrarContrasena;
  }

  siguientePaso(): void {
    this.error = '';
    if (!this.conductor.nombre || !this.conductor.apellido || !this.conductor.email || !this.conductor.contrasena) {
      this.error = 'Por favor completa todos los campos obligatorios';
      return;
    }
    if (this.conductor.contrasena !== this.conductor.confirmar_contrasena) {
      this.error = 'Las contraseñas no coinciden';
      return;
    }
    if (this.conductor.contrasena.length < 6) {
      this.error = 'La contraseña debe tener al menos 6 caracteres';
      return;
    }
    this.paso = 3;
  }

  registrarse(): void {
    this.error = '';
    if (!this.vehiculo.marca || !this.vehiculo.modelo || !this.vehiculo.placa) {
      this.error = 'Por favor completa los campos obligatorios del vehículo';
      return;
    }

    this.cargando = true;

    const payload = {
      nombre: this.conductor.nombre,
      apellido: this.conductor.apellido,
      email: this.conductor.email,
      telefono: this.conductor.telefono,
      contrasena: this.conductor.contrasena
    };

    this.authService.registro(payload).subscribe({
      next: (usuario) => {
        // Login automático para obtener token
        const body = new URLSearchParams();
        body.set('username', this.conductor.email);
        body.set('password', this.conductor.contrasena);

        this.http.post<any>('https://autofix-production-0c6c.up.railway.app/auth/login', body.toString(), {
          headers: { 'Content-Type': 'application/x-www-form-urlencoded' }
        }).subscribe({
          next: (respuesta) => {
            this.authService.guardarToken(respuesta.access_token);
            // Registrar vehículo
            const vehiculoPayload = { ...this.vehiculo, usuario_id: usuario.id };
            this.vehiculosService.crearVehiculo(vehiculoPayload).subscribe({
              next: () => {
                this.exito = 'Cuenta creada exitosamente!';
                this.cargando = false;
                setTimeout(() => this.router.navigate(['/dashboard']), 2000);
              },
              error: () => {
                this.exito = 'Cuenta creada! Pero no se pudo registrar el vehículo.';
                this.cargando = false;
                setTimeout(() => this.router.navigate(['/dashboard']), 2000);
              }
            });
          },
          error: () => {
            this.cargando = false;
            this.router.navigate(['/login']);
          }
        });
      },
      error: (err) => {
        this.error = err.error?.detail || 'Error al crear la cuenta';
        this.cargando = false;
      }
    });
  }
}