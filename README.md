# Spese-Viaggi

App web personale per gestire le spese di viaggio da iPhone e Mac.

## Funzioni

- viaggi e spese con identificativi UUID stabili
- rinomina dei viaggi senza modificare le spese associate
- salvataggio locale utilizzabile anche senza accesso
- sincronizzazione multi-dispositivo tramite Supabase Auth, Database e Realtime
- migrazione iniziale verificata, con copia locale precedente alla migrazione
- backup JSON completo e import/export CSV
- annullamento immediato delle eliminazioni

## Sicurezza Supabase

Le tabelle `trips` ed `expenses` hanno Row Level Security attiva. Il browser usa esclusivamente la chiave pubblicabile e ogni account può leggere o modificare soltanto le proprie righe. Lo schema riproducibile è in `supabase/migrations/`.
