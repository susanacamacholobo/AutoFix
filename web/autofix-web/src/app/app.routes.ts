import { Routes } from '@angular/router';
import { LoginComponent } from './pages/login/login';
import { Dashboard } from './pages/dashboard/dashboard';
import { RolesComponent } from './pages/roles/roles';
import { PermisosComponent } from './pages/permisos/permisos';
import { RegistroComponent } from './pages/registro/registro';
import { MisVehiculosComponent } from './pages/mis-vehiculos/mis-vehiculos';

export const routes: Routes = [
  { path: '', redirectTo: 'login', pathMatch: 'full' },
  { path: 'login', component: LoginComponent },
  { path: 'registro', component: RegistroComponent },
  { path: 'dashboard', component: Dashboard },
  { path: 'roles', component: RolesComponent },
  { path: 'permisos', component: PermisosComponent },
  { path: 'mis-vehiculos', component: MisVehiculosComponent },
];