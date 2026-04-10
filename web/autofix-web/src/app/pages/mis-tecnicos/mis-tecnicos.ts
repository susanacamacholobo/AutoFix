import { Component, OnInit, ChangeDetectorRef } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { RouterLink } from '@angular/router';
import { TalleresService } from '../../services/talleres';
import { AuthService } from '../../services/auth';
import { HttpClient } from '@angular/common/http';

@Component({
  selector: 'app-mis-tecnicos',
  standalone: true,
  imports: [CommonModule, FormsModule, RouterLink],
  templateUrl: './mis-tecnicos.html',
  styleUrl: './mis-tecnicos.css'
})
export class MisTecnicosComponent implements OnInit {

  tecnicos: any[] = [];
  tallerId: number = 0;
  nuevoTecnico = {
    nombre: '',
    apellido: '',
    telefono: '',
    especialidad: ''
  };
  tecnicoEditando: any = null;
  error: string = '';
  exito: string = '';
  cargando: boolean = false;
  mostrarFormulario: boolean = false;

  constructor(
    private talleresService: TalleresService,
    private authService: AuthService,
    private http: HttpClient,
    private cdr: ChangeDetectorRef
  ) {}

  ngOnInit(): void {
    this.obtenerTallerId();
  }

  obtenerTallerId(): void {
    this.http.get<any>('http://127.0.0.1:8000/talleres/mi-taller', {
      headers: { 'Authorization': `Bearer ${this.authService.obtenerToken()}` }
    }).subscribe({
      next: (taller) => {
        this.tallerId = taller.id;
        this.cargarTecnicos();
      },
      error: () => this.error = 'Error al obtener datos del taller'
    });
  }

  cargarTecnicos(): void {
    this.talleresService.listarTecnicos(this.tallerId).subscribe({
      next: (tecnicos) => {
        this.tecnicos = tecnicos;
        this.cdr.detectChanges();
      },
      error: () => this.error = 'Error al cargar técnicos'
    });
  }

  agregarTecnico(): void {
    this.error = '';
    if (!this.nuevoTecnico.nombre || !this.nuevoTecnico.apellido) {
      this.error = 'Nombre y apellido son obligatorios';
      return;
    }

    this.cargando = true;
    const payload = { ...this.nuevoTecnico, taller_id: this.tallerId };

    this.talleresService.crearTecnico(this.tallerId, payload).subscribe({
      next: () => {
        this.exito = 'Técnico registrado correctamente';
        this.nuevoTecnico = { nombre: '', apellido: '', telefono: '', especialidad: '' };
        this.mostrarFormulario = false;
        this.cargando = false;
        this.cargarTecnicos();
        setTimeout(() => this.exito = '', 3000);
      },
      error: () => {
        this.error = 'Error al registrar técnico';
        this.cargando = false;
      }
    });
  }

  editarTecnico(tecnico: any): void {
    this.tecnicoEditando = { ...tecnico };
  }

  guardarEdicion(): void {
    this.talleresService.actualizarTecnico(this.tallerId, this.tecnicoEditando.id, this.tecnicoEditando).subscribe({
      next: () => {
        this.exito = 'Técnico actualizado correctamente';
        this.tecnicoEditando = null;
        this.cargarTecnicos();
        setTimeout(() => this.exito = '', 3000);
      },
      error: () => this.error = 'Error al actualizar técnico'
    });
  }

  toggleDisponibilidad(tecnico: any): void {
    this.talleresService.actualizarTecnico(this.tallerId, tecnico.id, { disponible: !tecnico.disponible }).subscribe({
      next: () => {
        this.cargarTecnicos();
        this.exito = `Técnico ${tecnico.disponible ? 'marcado como no disponible' : 'marcado como disponible'}`;
        setTimeout(() => this.exito = '', 3000);
      },
      error: () => this.error = 'Error al actualizar técnico'
    });
  }

  eliminarTecnico(tecnico: any): void {
    this.talleresService.actualizarTecnico(this.tallerId, tecnico.id, { activo: !tecnico.activo }).subscribe({
      next: () => {
        this.exito = `Técnico ${tecnico.activo ? 'desactivado' : 'activado'} correctamente`;
        this.cargarTecnicos();
        setTimeout(() => this.exito = '', 3000);
      },
      error: () => this.error = 'Error al actualizar técnico'
    });
  }

  cancelarEdicion(): void {
    this.tecnicoEditando = null;
  }
}