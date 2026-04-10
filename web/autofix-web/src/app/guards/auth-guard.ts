import { Injectable } from '@angular/core';
import { CanActivate, Router, ActivatedRouteSnapshot } from '@angular/router';
import { AuthService } from '../services/auth';

@Injectable({
  providedIn: 'root'
})
export class AuthGuard implements CanActivate {

  constructor(private authService: AuthService, private router: Router) {}

  canActivate(route: ActivatedRouteSnapshot): boolean {
    const token = this.authService.obtenerToken();

    if (!token) {
      this.router.navigate(['/login']);
      return false;
    }

    const rolesPermitidos = route.data['roles'] as string[];

    if (rolesPermitidos && rolesPermitidos.length > 0) {
      const payload = JSON.parse(atob(token.split('.')[1]));
      const rolUsuario = payload.rol?.toLowerCase();

      if (!rolesPermitidos.includes(rolUsuario)) {
        this.router.navigate(['/dashboard']);
        return false;
      }
    }

    return true;
  }
}