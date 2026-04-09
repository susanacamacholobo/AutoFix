import { Component, OnInit, ChangeDetectorRef } from '@angular/core';
import { CommonModule } from '@angular/common';
import { RouterLink } from '@angular/router';
import { PermisosService } from '../../services/permisos';
import { RolesService } from '../../services/roles';

@Component({
  selector: 'app-permisos',
  standalone: true,
  imports: [CommonModule, RouterLink],
  templateUrl: './permisos.html',
  styleUrl: './permisos.css'
})
export class PermisosComponent implements OnInit {

  roles: any[] = [];
  permisos: any[] = [];
  permisosDelRol: any[] = [];
  rolSeleccionado: any = null;
  exito: string = '';
  error: string = '';

  constructor(
    private permisosService: PermisosService,
    private rolesService: RolesService,
    private cdr: ChangeDetectorRef
  ) {}

  ngOnInit(): void {
    this.cargarRoles();
    this.cargarPermisos();
  }

  cargarRoles(): void {
    this.rolesService.listarRoles().subscribe({
      next: (roles) => {
        this.roles = roles;
        this.cdr.detectChanges();
      },
      error: () => this.error = 'Error al cargar roles'
    });
  }

  cargarPermisos(): void {
    this.permisosService.listarPermisos().subscribe({
      next: (permisos) => {
        this.permisos = permisos;
        this.cdr.detectChanges();
      },
      error: () => this.error = 'Error al cargar permisos'
    });
  }

  seleccionarRol(rol: any): void {
    this.rolSeleccionado = rol;
    this.permisosService.listarPermisosPorRol(rol.id).subscribe({
      next: (permisos) => {
        this.permisosDelRol = permisos;
        this.cdr.detectChanges();
      },
      error: () => this.error = 'Error al cargar permisos del rol'
    });
  }

  tienePermiso(permisoId: number): boolean {
    return this.permisosDelRol.some(p => p.id === permisoId);
  }

  togglePermiso(permiso: any): void {
    if (!this.rolSeleccionado) return;

    if (this.tienePermiso(permiso.id)) {
      this.permisosService.removerPermiso(this.rolSeleccionado.id, permiso.id).subscribe({
        next: () => {
          this.permisosDelRol = this.permisosDelRol.filter(p => p.id !== permiso.id);
          this.exito = `Permiso "${permiso.nombre}" removido del rol`;
          this.cdr.detectChanges();
          setTimeout(() => this.exito = '', 3000);
        },
        error: () => this.error = 'Error al remover permiso'
      });
    } else {
      this.permisosService.asignarPermiso(this.rolSeleccionado.id, permiso.id).subscribe({
        next: () => {
          this.permisosDelRol.push(permiso);
          this.exito = `Permiso "${permiso.nombre}" asignado al rol`;
          this.cdr.detectChanges();
          setTimeout(() => this.exito = '', 3000);
        },
        error: () => this.error = 'Error al asignar permiso'
      });
    }
  }
}