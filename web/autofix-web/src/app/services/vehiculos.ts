import { Injectable } from '@angular/core';
import { HttpClient, HttpHeaders } from '@angular/common/http';
import { Observable } from 'rxjs';
import { AuthService } from './auth';

@Injectable({
  providedIn: 'root'
})
export class VehiculosService {

  private apiUrl = 'http://127.0.0.1:8000';

  constructor(private http: HttpClient, private authService: AuthService) {}

  private getHeaders(): HttpHeaders {
    const token = this.authService.obtenerToken();
    return new HttpHeaders({ 'Authorization': `Bearer ${token}` });
  }

  listarMisVehiculos(): Observable<any[]> {
    return this.http.get<any[]>(`${this.apiUrl}/vehiculos/mis-vehiculos`, {
      headers: this.getHeaders()
    });
  }

  crearVehiculo(vehiculo: any): Observable<any> {
    return this.http.post(`${this.apiUrl}/vehiculos/`, vehiculo, {
      headers: this.getHeaders()
    });
  }

  eliminarVehiculo(id: number): Observable<any> {
    return this.http.delete(`${this.apiUrl}/vehiculos/${id}`, {
      headers: this.getHeaders()
    });
  }
}