import { Injectable } from '@angular/core';
import { HttpClient, HttpHeaders } from '@angular/common/http';
import { Observable } from 'rxjs';
import { AuthService } from './auth';

@Injectable({
  providedIn: 'root'
})
export class RolesService {

  private apiUrl = 'http://127.0.0.1:8000';

  constructor(private http: HttpClient, private authService: AuthService) {}

  private getHeaders(): HttpHeaders {
    const token = this.authService.obtenerToken();
    return new HttpHeaders({
      'Authorization': `Bearer ${token}`
    });
  }

  listarRoles(): Observable<any[]> {
    return this.http.get<any[]>(`${this.apiUrl}/roles/`, {
      headers: this.getHeaders()
    });
  }

  crearRol(nombre: string, descripcion: string): Observable<any> {
    return this.http.post(`${this.apiUrl}/roles/`, { nombre, descripcion }, {
      headers: this.getHeaders()
    });
  }

  actualizarRol(id: number, datos: any): Observable<any> {
    return this.http.put(`${this.apiUrl}/roles/${id}`, datos, {
      headers: this.getHeaders()
    });
  }

  asignarRol(usuarioId: number, rolId: number): Observable<any> {
    return this.http.post(`${this.apiUrl}/roles/${usuarioId}/asignar/${rolId}`, {}, {
      headers: this.getHeaders()
    });
  }
}