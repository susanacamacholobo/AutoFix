import { Component, OnInit, ChangeDetectorRef } from '@angular/core';
import { CommonModule } from '@angular/common';
import { RouterLink } from '@angular/router';
import { IncidentesService } from '../../services/incidentes';
import { TalleresService } from '../../services/talleres';
import { AuthService } from '../../services/auth';
import { HttpClient } from '@angular/common/http';
import { FiltrarTipoPipe } from '../../pipes/filtrar-tipo-pipe';

@Component({
  selector: 'app-incidentes',
  standalone: true,
  imports: [CommonModule, RouterLink, FiltrarTipoPipe],
  templateUrl: './incidentes.html',
  styleUrl: './incidentes.css'
})
export class IncidentesComponent implements OnInit {

  incidentes: any[] = [];
  tallerId: number = 0;
  tecnicos: any[] = [];
  todosLosTecnicos: any[] = [];
  incidenteSeleccionado: any = null;
  error: string = '';
  exito: string = '';
  filtro: string = 'pendiente';
  evidencias: any[] = [];
  rechazos: any[] = [];

  constructor(
    private incidentesService: IncidentesService,
    private talleresService: TalleresService,
    private authService: AuthService,
    private http: HttpClient,
    private cdr: ChangeDetectorRef
  ) { }

  ngOnInit(): void {
    this.obtenerTaller();
  }

  obtenerTaller(): void {
    this.http.get<any>('https://autofix-production-0c6c.up.railway.app/talleres/mi-taller', {
      headers: { 'Authorization': `Bearer ${this.authService.obtenerToken()}` }
    }).subscribe({
      next: (taller) => {
        this.tallerId = taller.id;
        this.talleresService.listarTecnicos(taller.id).subscribe({
          next: (tecnicos) => {
            this.todosLosTecnicos = tecnicos.filter((t: any) => t.activo);
            this.tecnicos = tecnicos.filter((t: any) => t.activo && t.disponible);
          },
          error: () => { }
        });
        this.cargarIncidentes();
        this.cargarRechazos();
      },
      error: () => this.cargarIncidentes()
    });
  }

  cargarIncidentes(): void {
    this.incidentesService.listarTodos().subscribe({
      next: (incidentes) => {
        this.incidentes = incidentes.filter((i: any) =>
          i.estado === 'pendiente' ||
          i.taller_id === this.tallerId
        );
        this.cdr.detectChanges();
      },
      error: () => this.error = 'Error al cargar incidentes'
    });
  }

  get incidentesFiltrados(): any[] {
    if (this.filtro === 'todos') return this.incidentes;
    return this.incidentes.filter(i => i.estado === this.filtro);
  }

  seleccionarIncidente(incidente: any): void {
    this.incidenteSeleccionado = incidente;
    this.evidencias = [];
    this.incidentesService.listarEvidencias(incidente.id).subscribe({
      next: (evidencias) => {
        this.evidencias = evidencias;
        this.cdr.detectChanges();
      },
      error: () => { }
    });
  }

  aceptarIncidente(incidente: any): void {
    this.incidentesService.actualizarIncidente(incidente.id, {
      estado: 'en_proceso',
      taller_id: this.tallerId
    }).subscribe({
      next: () => {
        this.exito = 'Solicitud aceptada correctamente';
        this.incidenteSeleccionado = null;
        this.cargarIncidentes();
        setTimeout(() => this.exito = '', 3000);
      },
      error: () => this.error = 'Error al aceptar solicitud'
    });
  }

  rechazarIncidente(incidente: any): void {
    this.incidentesService.actualizarIncidente(incidente.id, {
      estado: 'rechazado'
    }).subscribe({
      next: () => {
        this.exito = 'Solicitud rechazada';
        this.incidenteSeleccionado = null;
        this.cargarIncidentes();
        setTimeout(() => this.exito = '', 3000);
      },
      error: () => this.error = 'Error al rechazar solicitud'
    });
  }

  asignarTecnico(incidente: any, tecnicoId: number): void {
    this.incidentesService.actualizarIncidente(incidente.id, {
      tecnico_id: tecnicoId
    }).subscribe({
      next: () => {
        this.exito = 'Técnico asignado correctamente';
        this.cargarIncidentes();
        setTimeout(() => this.exito = '', 3000);
      },
      error: () => this.error = 'Error al asignar técnico'
    });
  }

  actualizarEstado(incidente: any, estado: string): void {
    this.incidentesService.actualizarIncidente(incidente.id, { estado }).subscribe({
      next: () => {
        this.exito = `Emergencia marcada como ${estado}`;
        this.incidenteSeleccionado = null;
        this.cargarIncidentes();
        setTimeout(() => this.exito = '', 3000);
      },
      error: () => this.error = 'Error al actualizar estado'
    });
  }

  getBadgeClass(estado: string): string {
    switch (estado) {
      case 'pendiente': return 'badge-warning';
      case 'en_proceso': return 'badge-info';
      case 'atendido': return 'badge-success';
      case 'rechazado': return 'badge-danger';
      default: return 'badge-warning';
    }
  }

  getPrioridadClass(prioridad: string): string {
    switch (prioridad) {
      case 'alta': return 'prioridad-alta';
      case 'media': return 'prioridad-media';
      case 'baja': return 'prioridad-baja';
      default: return 'prioridad-media';
    }
  }

  abrirFoto(url: string): void {
    window.open(url, '_blank');
  }

  cargarRechazos(): void {
    if (this.tallerId === 0) return;
    this.incidentesService.historialRechazos(this.tallerId).subscribe({
      next: (rechazos) => {
        this.rechazos = rechazos;
        this.cdr.detectChanges();
      },
      error: (err) => { }
    });
  }

  cambiarFiltro(filtro: string): void {
    this.filtro = filtro;
    this.cdr.detectChanges();
  }

  obtenerNombreTecnico(tecnicoId: number): string {
    const tecnico = this.todosLosTecnicos.find(t => t.id === tecnicoId);
    return tecnico ? `${tecnico.nombre} ${tecnico.apellido}` : 'Técnico asignado';
  }
}