import { Injectable } from '@angular/core';
import { HttpClient, HttpHeaders } from '@angular/common/http';
import { Observable } from 'rxjs';
import { AuthService } from './auth';

@Injectable({
  providedIn: 'root'
})
export class PermisosService {

  private apiUrl = 'https://autofix-production-0c6c.up.railway.app';

  constructor(private http: HttpClient, private authService: AuthService) {}

  private getHeaders(): HttpHeaders {
    const token = this.authService.obtenerToken();
    return new HttpHeaders({ 'Authorization': `Bearer ${token}` });
  }

  listarPermisos(): Observable<any[]> {
    return this.http.get<any[]>(`${this.apiUrl}/permisos/`, {
      headers: this.getHeaders()
    });
  }

  listarPermisosPorRol(rolId: number): Observable<any[]> {
    return this.http.get<any[]>(`${this.apiUrl}/permisos/rol/${rolId}`, {
      headers: this.getHeaders()
    });
  }

  asignarPermiso(rolId: number, permisoId: number): Observable<any> {
    return this.http.post(`${this.apiUrl}/permisos/rol/${rolId}/asignar/${permisoId}`, {}, {
      headers: this.getHeaders()
    });
  }

  removerPermiso(rolId: number, permisoId: number): Observable<any> {
    return this.http.delete(`${this.apiUrl}/permisos/rol/${rolId}/remover/${permisoId}`, {
      headers: this.getHeaders()
    });
  }
}