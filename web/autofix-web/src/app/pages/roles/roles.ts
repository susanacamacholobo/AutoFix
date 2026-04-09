import { Component, OnInit, ChangeDetectorRef } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { RolesService } from '../../services/roles';
import { RouterLink } from '@angular/router';

@Component({
  selector: 'app-roles',
  standalone: true,
  imports: [CommonModule, FormsModule, RouterLink],
  templateUrl: './roles.html',
  styleUrl: './roles.css'
})
export class RolesComponent implements OnInit {

  roles: any[] = [];
  nuevoRol = { nombre: '', descripcion: '' };
  rolEditando: any = null;
  error: string = '';
  exito: string = '';

  constructor(
    private rolesService: RolesService,
    private cdr: ChangeDetectorRef
  ) {}

  ngOnInit(): void {
    this.cargarRoles();
  }

  cargarRoles(): void {
    this.rolesService.listarRoles().subscribe({
      next: (roles) => {
        this.roles = roles;
        this.cdr.detectChanges();
      },
      error: () => this.error = 'Error al cargar los roles'
    });
  }

  crearRol(): void {
    if (!this.nuevoRol.nombre) return;
    this.rolesService.crearRol(this.nuevoRol.nombre, this.nuevoRol.descripcion).subscribe({
      next: () => {
        this.exito = 'Rol creado correctamente';
        this.nuevoRol = { nombre: '', descripcion: '' };
        this.cargarRoles();
        setTimeout(() => this.exito = '', 3000);
      },
      error: () => this.error = 'Error al crear el rol'
    });
  }

  editarRol(rol: any): void {
    this.rolEditando = { ...rol };
  }

  guardarEdicion(): void {
    this.rolesService.actualizarRol(this.rolEditando.id, this.rolEditando).subscribe({
      next: () => {
        this.exito = 'Rol actualizado correctamente';
        this.rolEditando = null;
        this.cargarRoles();
        setTimeout(() => this.exito = '', 3000);
      },
      error: () => this.error = 'Error al actualizar el rol'
    });
  }

  desactivarRol(rol: any): void {
    this.rolesService.actualizarRol(rol.id, { activo: !rol.activo }).subscribe({
      next: () => {
        this.cargarRoles();
        this.exito = `Rol ${rol.activo ? 'desactivado' : 'activado'} correctamente`;
        setTimeout(() => this.exito = '', 3000);
      },
      error: () => this.error = 'Error al actualizar el rol'
    });
  }

  cancelarEdicion(): void {
    this.rolEditando = null;
  }
}