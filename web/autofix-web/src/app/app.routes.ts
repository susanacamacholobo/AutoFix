import { Routes } from '@angular/router';
import { LoginComponent } from './pages/login/login';
import { Dashboard } from './pages/dashboard/dashboard';
import { RolesComponent } from './pages/roles/roles';
import { PermisosComponent } from './pages/permisos/permisos';
import { RegistroComponent } from './pages/registro/registro';
import { RegistroTallerComponent } from './pages/registro-taller/registro-taller';
import { MisVehiculosComponent } from './pages/mis-vehiculos/mis-vehiculos';
import { MisTecnicosComponent } from './pages/mis-tecnicos/mis-tecnicos';
import { AuthGuard } from './guards/auth-guard';

export const routes: Routes = [
  { path: '', redirectTo: 'login', pathMatch: 'full' },
  { path: 'login', component: LoginComponent },
  { path: 'registro', component: RegistroComponent },
  { path: 'registro-taller', component: RegistroTallerComponent },
  {
    path: 'dashboard',
    component: Dashboard,
    canActivate: [AuthGuard]
  },
  {
    path: 'roles',
    component: RolesComponent,
    canActivate: [AuthGuard],
    data: { roles: ['administrador'] }
  },
  {
    path: 'permisos',
    component: PermisosComponent,
    canActivate: [AuthGuard],
    data: { roles: ['administrador'] }
  },
  {
    path: 'mis-vehiculos',
    component: MisVehiculosComponent,
    canActivate: [AuthGuard],
    data: { roles: ['conductor', 'administrador'] }
  },
  {
    path: 'mis-tecnicos',
    component: MisTecnicosComponent,
    canActivate: [AuthGuard],
    data: { roles: ['taller', 'administrador'] }
  },
];