import { Routes } from '@angular/router';
import { LoginComponent } from './pages/login/login';
import { Dashboard } from './pages/dashboard/dashboard';
import { RolesComponent } from './pages/roles/roles';
import { RegistroTallerComponent } from './pages/registro-taller/registro-taller';
import { MisTecnicosComponent } from './pages/mis-tecnicos/mis-tecnicos';
import { IncidentesComponent } from './pages/incidentes/incidentes';
import { AuthGuard } from './guards/auth-guard';

export const routes: Routes = [
  { path: '', redirectTo: 'login', pathMatch: 'full' },
  { path: 'login', component: LoginComponent },
  { path: 'registro', redirectTo: 'registro-taller', pathMatch: 'full' },
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
    path: 'mis-tecnicos',
    component: MisTecnicosComponent,
    canActivate: [AuthGuard],
    data: { roles: ['taller', 'administrador'] }
  },
  {
    path: 'incidentes',
    component: IncidentesComponent,
    canActivate: [AuthGuard],
    data: { roles: ['taller', 'administrador'] }
  },
];