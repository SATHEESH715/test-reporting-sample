import { Component, inject } from '@angular/core';
import { HttpClient } from '@angular/common/http';
import { toSignal } from '@angular/core/rxjs-interop';

export interface TenancyItem {
  id: string;
  tenancyNumber: number;
  tenant: string;
  property: string;
  status: string;
}

@Component({
  selector: 'app-root',
  templateUrl: './app.html',
  styleUrl: './app.css',
})
export class App {
  private readonly http = inject(HttpClient);
  protected readonly tenancies = toSignal(this.http.get<TenancyItem[]>('/api/tenancies'), {
    initialValue: [] as TenancyItem[],
  });
}
