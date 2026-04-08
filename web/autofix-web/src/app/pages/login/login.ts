import { Component } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { Router } from '@angular/router';
import { AuthService } from '../../services/auth';

@Component({
  selector: 'app-login',
  standalone: true,
  imports: [CommonModule, FormsModule],
  templateUrl: './login.html',
  styleUrl: './login.css'
})
export class LoginComponent {

  email: string = '';
  contrasena: string = '';
  error: string = '';
  cargando: boolean = false;

  constructor(private authService: AuthService, private router: Router) {}

  iniciarSesion(): void {
    this.error = '';
    this.cargando = true;

    this.authService.login(this.email, this.contrasena).subscribe({
      next: (respuesta) => {
        this.authService.guardarToken(respuesta.access_token);
        this.cargando = false;
        this.router.navigate(['/dashboard']);
      },
      error: (err) => {
        this.error = 'Email o contraseña incorrectos';
        this.cargando = false;
      }
    });
  }
}