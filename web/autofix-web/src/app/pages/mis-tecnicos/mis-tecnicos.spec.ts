import { ComponentFixture, TestBed } from '@angular/core/testing';

import { MisTecnicos } from './mis-tecnicos';

describe('MisTecnicos', () => {
  let component: MisTecnicos;
  let fixture: ComponentFixture<MisTecnicos>;

  beforeEach(async () => {
    await TestBed.configureTestingModule({
      imports: [MisTecnicos],
    }).compileComponents();

    fixture = TestBed.createComponent(MisTecnicos);
    component = fixture.componentInstance;
    await fixture.whenStable();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});
