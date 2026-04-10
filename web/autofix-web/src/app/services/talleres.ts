import { Injectable } from '@angular/core';
import { HttpClient, HttpHeaders } from '@angular/common/http';
import { Observable } from 'rxjs';
import { AuthService } from './auth';

@Injectable({
  providedIn: 'root'
})
export class TalleresService {

  private apiUrl = 'http://127.0.0.1:8000';

  constructor(private http: HttpClient, private authService: AuthService) {}

  private getHeaders(): HttpHeaders {
    const token = this.authService.obtenerToken();
    return new HttpHeaders({ 'Authorization': `Bearer ${token}` });
  }

  registrarTaller(taller: any): Observable<any> {
    return this.http.post(`${this.apiUrl}/talleres/registro`, taller);
  }

  listarTalleres(): Observable<any[]> {
    return this.http.get<any[]>(`${this.apiUrl}/talleres/`, {
      headers: this.getHeaders()
    });
  }

  listarTecnicos(tallerId: number): Observable<any[]> {
    return this.http.get<any[]>(`${this.apiUrl}/talleres/${tallerId}/tecnicos`, {
      headers: this.getHeaders()
    });
  }

  crearTecnico(tallerId: number, tecnico: any): Observable<any> {
    return this.http.post(`${this.apiUrl}/talleres/${tallerId}/tecnicos`, tecnico, {
      headers: this.getHeaders()
    });
  }

  actualizarTecnico(tallerId: number, tecnicoId: number, datos: any): Observable<any> {
    return this.http.put(`${this.apiUrl}/talleres/${tallerId}/tecnicos/${tecnicoId}`, datos, {
      headers: this.getHeaders()
    });
  }

  eliminarTecnico(tallerId: number, tecnicoId: number): Observable<any> {
    return this.http.delete(`${this.apiUrl}/talleres/${tallerId}/tecnicos/${tecnicoId}`, {
      headers: this.getHeaders()
    });
  }
}