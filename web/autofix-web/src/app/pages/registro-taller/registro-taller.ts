import { Component } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { Router, RouterLink } from '@angular/router';
import { TalleresService } from '../../services/talleres';
import { AuthService } from '../../services/auth';
import { HttpClient } from '@angular/common/http';

@Component({
  selector: 'app-registro-taller',
  standalone: true,
  imports: [CommonModule, FormsModule, RouterLink],
  templateUrl: './registro-taller.html',
  styleUrl: './registro-taller.css'
})
export class RegistroTallerComponent {

  paso: number = 1;
  error: string = '';
  exito: string = '';
  cargando: boolean = false;
  mostrarContrasena: boolean = false;
  tallerCreado: any = null;

  taller = {
    nombre: '',
    email: '',
    telefono: '',
    direccion: '',
    especialidad: '',
    contrasena: '',
    confirmar_contrasena: ''
  };

  tecnico = {
    nombre: '',
    apellido: '',
    telefono: '',
    especialidad: ''
  };

  constructor(
    private talleresService: TalleresService,
    private authService: AuthService,
    private http: HttpClient,
    private router: Router
  ) {}

  toggleContrasena(): void {
    this.mostrarContrasena = !this.mostrarContrasena;
  }

  siguientePaso(): void {
    this.error = '';
    if (!this.taller.nombre || !this.taller.email || !this.taller.contrasena) {
      this.error = 'Por favor completa todos los campos obligatorios';
      return;
    }
    if (this.taller.contrasena !== this.taller.confirmar_contrasena) {
      this.error = 'Las contraseñas no coinciden';
      return;
    }
    if (this.taller.contrasena.length < 6) {
      this.error = 'La contraseña debe tener al menos 6 caracteres';
      return;
    }
    this.paso = 2;
  }

  registrarse(): void {
    this.error = '';
    if (!this.tecnico.nombre || !this.tecnico.apellido) {
      this.error = 'Por favor ingresa al menos un técnico';
      return;
    }

    this.cargando = true;

    const payload = {
      nombre: this.taller.nombre,
      email: this.taller.email,
      telefono: this.taller.telefono,
      direccion: this.taller.direccion,
      especialidad: this.taller.especialidad,
      contrasena: this.taller.contrasena
    };

    this.talleresService.registrarTaller(payload).subscribe({
      next: (tallerCreado) => {
        this.tallerCreado = tallerCreado;

        // Login automático
        const body = new URLSearchParams();
        body.set('username', this.taller.email);
        body.set('password', this.taller.contrasena);

        this.http.post<any>('http://127.0.0.1:8000/auth/login', body.toString(), {
          headers: { 'Content-Type': 'application/x-www-form-urlencoded' }
        }).subscribe({
          next: (respuesta) => {
            this.authService.guardarToken(respuesta.access_token);

            // Crear técnico
            const tecnicoPayload = {
              taller_id: tallerCreado.id,
              nombre: this.tecnico.nombre,
              apellido: this.tecnico.apellido,
              telefono: this.tecnico.telefono,
              especialidad: this.tecnico.especialidad
            };

            this.talleresService.crearTecnico(tallerCreado.id, tecnicoPayload).subscribe({
              next: () => {
                this.exito = 'Taller registrado exitosamente!';
                this.cargando = false;
                setTimeout(() => this.router.navigate(['/dashboard']), 2000);
              },
              error: () => {
                this.exito = 'Taller creado! Puedes agregar técnicos desde el dashboard.';
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
        this.error = err.error?.detail || 'Error al registrar el taller';
        this.cargando = false;
      }
    });
  }
}