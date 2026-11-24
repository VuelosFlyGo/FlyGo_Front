# Product

<!-- impeccable:product-schema 1 -->

## Platform

adaptive

## Users

- Clientes que buscan vuelos, seleccionan asientos y administran sus reservas.
- Administradores que crean, editan y desactivan vuelos, rutas, horarios, precios y capacidad.

## Product Purpose

FlyGo es una aplicación distribuida de reservas de vuelos. Su objetivo es ofrecer un flujo claro y confiable entre un cliente Flutter, una API REST Flask y PostgreSQL en Supabase.

## Positioning

Una experiencia académica completa que hace visible la arquitectura orientada a servicios mediante operaciones reales de autenticación, consulta, reserva y administración de vuelos.

## Operating Context

La aplicación se utiliza en web y puede ejecutarse como aplicación Flutter móvil. Los usuarios trabajan con rutas, fechas, horarios, precios, disponibilidad y selección visual de asientos.

## Capabilities and Constraints

- Autenticación mediante usuario, contraseña y token.
- Roles `admin` y `cliente` con autorización verificada también en el backend.
- El administrador crea, edita y desactiva vuelos.
- El cliente consulta vuelos, reserva asientos y gestiona sus reservas.
- La interfaz consume servicios REST en formato JSON.
- La base de datos PostgreSQL está alojada en Supabase con RLS habilitado.

## Brand Commitments

- Nombre confirmado: FlyGo.
- Los clientes deben ver todos los vuelos disponibles al ingresar y filtrar únicamente mediante ciudades existentes en el inventario.
- Identidad confirmada: interfaz clara y fotográfica, azul eléctrico y símbolo F inspirado en un ala de avión.
- La identidad debe comunicar aviación, rutas y tecnología.
- El usuario pidió una presencia visual llamativa y delegó la elección de la mejor solución de logo.
- Las referencias suministradas usan azul profundo, cian, rutas aéreas, aviones y paneles operativos.

## Evidence on Hand

- Aplicación Flutter funcional con flujos separados por rol.
- API Flask y esquema Supabase en funcionamiento.
- Diagrama de arquitectura y flujo proporcionado por el usuario.
- Guía académica APE 4 con requisitos funcionales y técnicos.

## Product Principles

- El rol del usuario debe reconocerse en segundos.
- Toda acción crítica debe explicar su efecto y estado.
- Los datos de vuelo son el centro visual de la experiencia.
- La identidad aeronáutica debe reforzar la tarea, no competir con ella.
- El mismo sistema debe mantenerse claro en escritorio y móvil.

## Accessibility & Inclusion

Contraste legible, controles con etiquetas semánticas, estados visibles y composición adaptable para escritorio y móvil.
