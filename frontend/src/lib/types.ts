export interface SimulationParams {
  days: number;
  e0: number;
  i0: number;
  beta_i: number;
  beta_h: number;
  beta_f: number;
  incubation_days: number;
  hosp_days: number;
  gamma_f: number;
  gamma_r: number;
  gamma_hr: number;
  gamma_hd: number;
  funeral_days?: number;
}

export interface SimulationStats {
  total_infected: number;
  total_deaths: number;
  cfr: number;
  peak_I: number;
}

export interface SimulationData {
  times: number[];
  S: number[];
  E: number[];
  I: number[];
  H: number[];
  F: number[];
  R: number[];
  stats: SimulationStats;
  [key: string]: any;
}
