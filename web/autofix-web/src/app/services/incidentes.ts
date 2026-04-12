import { Injectable } from '@angular/core';
import { HttpClient, HttpHeaders } from '@angular/common/http';
import { Observable } from 'rxjs';
import { AuthService } from './auth';

@Injectable({
  providedIn: 'root'
})
export class IncidentesService {

  private apiUrl = 'https://autofix-production-0c6c.up.railway.app';

  constructor(private http: HttpClient, private authService: AuthService) {}

  private getHeaders(): HttpHeaders {
    const token = this.authService.obtenerToken();
    return new HttpHeaders({ 'Authorization': `Bearer ${token}` });
  }

  listarPendientes(): Observable<any[]> {
    return this.http.get<any[]>(`${this.apiUrl}/incidentes/pendientes`, {
      headers: this.getHeaders()
    });
  }

  listarTodos(): Observable<any[]> {
    return this.http.get<any[]>(`${this.apiUrl}/incidentes/`, {
      headers: this.getHeaders()
    });
  }

  listarMisIncidentes(): Observable<any[]> {
    return this.http.get<any[]>(`${this.apiUrl}/incidentes/mis-incidentes`, {
      headers: this.getHeaders()
    });
  }

  obtenerIncidente(id: number): Observable<any> {
    return this.http.get<any>(`${this.apiUrl}/incidentes/${id}`, {
      headers: this.getHeaders()
    });
  }

  actualizarIncidente(id: number, datos: any): Observable<any> {
    return this.http.put(`${this.apiUrl}/incidentes/${id}`, datos, {
      headers: this.getHeaders()
    });
  }

  crearIncidente(incidente: any): Observable<any> {
    return this.http.post(`${this.apiUrl}/incidentes/`, incidente, {
      headers: this.getHeaders()
    });
  }

  listarEvidencias(incidenteId: number): Observable<any[]> {
    return this.http.get<any[]>(`${this.apiUrl}/evidencias/${incidenteId}`, {
      headers: this.getHeaders()
    });
  }

  historialRechazos(tallerId: number): Observable<any[]> {
    return this.http.get<any[]>(`${this.apiUrl}/incidentes/historial-rechazos/${tallerId}`, {
      headers: this.getHeaders()
    });
  }
}