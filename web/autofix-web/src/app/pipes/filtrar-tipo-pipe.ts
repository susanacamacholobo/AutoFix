import { Pipe, PipeTransform } from '@angular/core';

@Pipe({
  name: 'filtrarTipo',
  standalone: true
})
export class FiltrarTipoPipe implements PipeTransform {
  transform(evidencias: any[], tipo: string): any[] {
    if (!evidencias) return [];
    return evidencias.filter(e => e.tipo === tipo);
  }
}