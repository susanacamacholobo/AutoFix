import { Component } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { Router, RouterLink } from '@angular/router';
import { AuthService } from '../../services/auth';

@Component({
  selector: 'app-registro',
  standalone: true,
  imports: [CommonModule, FormsModule, RouterLink],
  templateUrl: './registro.html',
  styleUrl: './registro.css'
})
export class RegistroComponent {

  datos = {
    nombre: '',
    apellido: '',
    email: '',
    telefono: '',
    contrasena: '',
    confirmar_contrasena: ''
  };

  error: string = '';
  exito: string = '';
  cargando: boolean = false;
  mostrarContrasena: boolean = false;

  constructor(private authService: AuthService, private router: Router) {}

  toggleContrasena(): void {
    this.mostrarContrasena = !this.mostrarContrasena;
  }

  registrarse(): void {
    this.error = '';

    if (this.datos.contrasena !== this.datos.confirmar_contrasena) {
      this.error = 'Las contraseñas no coinciden';
      return;
    }

    if (this.datos.contrasena.length < 6) {
      this.error = 'La contraseña debe tener al menos 6 caracteres';
      return;
    }

    this.cargando = true;

    const payload = {
      nombre: this.datos.nombre,
      apellido: this.datos.apellido,
      email: this.datos.email,
      telefono: this.datos.telefono,
      contrasena: this.datos.contrasena
    };

    this.authService.registro(payload).subscribe({
      next: () => {
        this.exito = 'Cuenta creada exitosamente!';
        this.cargando = false;
        setTimeout(() => this.router.navigate(['/login']), 2000);
      },
      error: (err) => {
        this.error = err.error?.detail || 'Error al crear la cuenta';
        this.cargando = false;
      }
    });
  }
}