import { Injectable } from '@angular/core';
import { HttpClient, HttpHeaders } from '@angular/common/http';
import { Observable } from 'rxjs';

@Injectable({
  providedIn: 'root'
})
export class AuthService {

  /////private apiUrl = 'https://autofix-production-0c6c.up.railway.app'; Cambiar luego
  private apiUrl = 'https://autofix-production-0c6c.up.railway.app';

  constructor(private http: HttpClient) {}

  login(email: string, contrasena: string): Observable<any> {
    const body = new URLSearchParams();
    body.set('username', email);
    body.set('password', contrasena);

    return this.http.post(`${this.apiUrl}/auth/login`, body.toString(), {
      headers: new HttpHeaders({'Content-Type': 'application/x-www-form-urlencoded'})
    });
  }

  registro(datos: any): Observable<any> {
    return this.http.post(`${this.apiUrl}/usuarios/registro`, datos);
  }

  logout(): void {
    localStorage.removeItem('token');
  }

  guardarToken(token: string): void {
    localStorage.setItem('token', token);
  }

  obtenerToken(): string | null {
    return localStorage.getItem('token');
  }

  estaAutenticado(): boolean {
    return !!this.obtenerToken();
  }
}