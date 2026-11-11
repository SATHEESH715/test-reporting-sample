import { Component, inject } from '@angular/core';
import { HttpClient } from '@angular/common/http';
import { toSignal } from '@angular/core/rxjs-interop';

export interface PropertyItem {
  id: string;
  propertyNumber: number;
  address: string;
  status: string;
}

@Component({
  selector: 'app-root',
  templateUrl: './app.html',
  styleUrl: './app.css',
})
export class App {
  private readonly http = inject(HttpClient);
  protected readonly properties = toSignal(this.http.get<PropertyItem[]>('/api/properties'), {
    initialValue: [] as PropertyItem[],
  });
}
