import { Component, OnInit, ChangeDetectorRef } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { RouterLink } from '@angular/router';
import { HttpClient } from '@angular/common/http';
import { VehiculosService } from '../../services/vehiculos';
import { AuthService } from '../../services/auth';

@Component({
  selector: 'app-mis-vehiculos',
  standalone: true,
  imports: [CommonModule, FormsModule, RouterLink],
  templateUrl: './mis-vehiculos.html',
  styleUrl: './mis-vehiculos.css'
})
export class MisVehiculosComponent implements OnInit {

  vehiculos: any[] = [];
  nuevoVehiculo: any = {
    marca: '',
    modelo: '',
    anio: null,
    placa: '',
    color: ''
  };
  error: string = '';
  exito: string = '';
  cargando: boolean = false;
  mostrarFormulario: boolean = false;

  constructor(
    private vehiculosService: VehiculosService,
    private authService: AuthService,
    private http: HttpClient,
    private cdr: ChangeDetectorRef
  ) {}

  ngOnInit(): void {
    this.cargarVehiculos();
  }

  cargarVehiculos(): void {
    this.vehiculosService.listarMisVehiculos().subscribe({
      next: (vehiculos) => {
        this.vehiculos = vehiculos;
        this.cdr.detectChanges();
      },
      error: () => this.error = 'Error al cargar vehículos'
    });
  }

  agregarVehiculo(): void {
    this.error = '';
    this.cargando = true;

    this.http.get<any>('https://autofix-production-0c6c.up.railway.app/usuarios/me', {
      headers: { 'Authorization': `Bearer ${this.authService.obtenerToken()}` }
    }).subscribe({
      next: (usuario) => {
        const payload = { ...this.nuevoVehiculo, usuario_id: usuario.id };
        this.vehiculosService.crearVehiculo(payload).subscribe({
          next: () => {
            this.exito = 'Vehículo registrado correctamente';
            this.nuevoVehiculo = { marca: '', modelo: '', anio: null, placa: '', color: '' };
            this.mostrarFormulario = false;
            this.cargando = false;
            this.cargarVehiculos();
            setTimeout(() => this.exito = '', 3000);
          },
          error: (err) => {
            this.error = err.error?.detail || 'Error al registrar vehículo';
            this.cargando = false;
          }
        });
      },
      error: () => {
        this.error = 'Error al obtener usuario';
        this.cargando = false;
      }
    });
  }

  eliminarVehiculo(id: number): void {
    this.vehiculosService.eliminarVehiculo(id).subscribe({
      next: () => {
        this.exito = 'Vehículo eliminado correctamente';
        this.cargarVehiculos();
        setTimeout(() => this.exito = '', 3000);
      },
      error: () => this.error = 'Error al eliminar vehículo'
    });
  }
}