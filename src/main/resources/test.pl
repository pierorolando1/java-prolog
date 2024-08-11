:- dynamic cliente/2.
:- dynamic cuenta/2.
:- dynamic prestamo/3.
:- dynamic transaccion/4.
:- dynamic relacion_cliente_cuenta/2.
:- dynamic relacion_cliente_prestamo/2.
:- dynamic relacion_cuenta_transaccion/2.
:- dynamic relacion_prestamo_transaccion/2.

% Entities
cliente(dni, nombre_cliente).
cuenta(id_cuenta, dni).
prestamo(id_prestamo, dni, estado).
transaccion(id_transaccion, id_cuenta_origen, id_cuenta_destino, monto).

% Relationships
relacion_cliente_cuenta(dni, id_cuenta).
relacion_cliente_prestamo(dni, id_prestamo).
relacion_cuenta_transaccion(id_cuenta, id_transaccion).
relacion_prestamo_transaccion(id_prestamo, id_transaccion).

% Example Data
cliente(74160675, 'Chris Vega').
cliente(60737330, 'Piero Rolando').

cuenta(1234, 74160675).
cuenta(5678, 60737330).
cuenta(9012, 74160675).  % Segunda cuenta para Chris Vega

cuenta(0000, 00000000). % Cuenta del banco

prestamo(P001, 74160675, al_dia).
prestamo(P002, 60737330, pagado).
prestamo(P003, 74160675, pagado).

transaccion(T000, 0000, 1234, 10000). % Deposito inicial
transaccion(T000, 0000, 5678, 5000). % Deposito inicial


transaccion(T001, 1234, 5678, 700).
transaccion(T002, 5678, 1234, 500).
transaccion(T003, 1234, 9012, 200).

relacion_cliente_cuenta(74160675, 1234).
relacion_cliente_cuenta(60737330, 5678).
relacion_cliente_cuenta(74160675, 9012).

relacion_cliente_prestamo(74160675, P001).
relacion_cliente_prestamo(60737330, P002).
relacion_cliente_prestamo(74160675, P003).

relacion_cuenta_transaccion(1234, T001).
relacion_cuenta_transaccion(5678, T001).
relacion_cuenta_transaccion(5678, T002).
relacion_cuenta_transaccion(1234, T002).
relacion_cuenta_transaccion(1234, T003).
relacion_cuenta_transaccion(9012, T003).

% Rules for loan evaluation
historial_crediticio(DNI, Historial) :-
    findall(Estado, (relacion_cliente_prestamo(DNI, IdPrestamo), prestamo(IdPrestamo, DNI, Estado)), Estados),
    evaluar_historial(Estados, Historial).

evaluar_historial(Estados, bueno) :- 
    \+ member(atrasado, Estados),
    \+ member(incobrable, Estados).
evaluar_historial(_, malo).

capacidad_pago(DNI, Capacidad) :-
    findall(Monto, (
        relacion_cliente_cuenta(DNI, IdCuenta),
        (transaccion(_, IdCuenta, _, Monto) ; transaccion(_, _, IdCuenta, Monto))
    ), Montos),
    sum_list(Montos, Total),
    evaluar_capacidad(Total, Capacidad).

evaluar_capacidad(Total, alta) :- Total > 5000.
evaluar_capacidad(Total, media) :- Total > 2000, Total =< 5000.
evaluar_capacidad(_, baja).

relacion_cuentas_prestamos_buena(DNI) :- 
    relacion_cliente_cuenta(DNI, Cuenta),
    relacion_cuenta_transaccion(Cuenta, _).

evaluar_prestamo(DNI, Viabilidad) :-
    historial_crediticio(DNI, Historial),
    capacidad_pago(DNI, Capacidad),
    (relacion_cuentas_prestamos_buena(DNI) -> Relacion = buena ; Relacion = mala),
    evaluar_factores(Historial, Capacidad, Relacion, Viabilidad).

evaluar_factores(bueno, alta, buena, viable).
evaluar_factores(bueno, media, buena, viable).
evaluar_factores(_, _, _, no_viable).

% Define the predicate to get loans by user ID
obtener_prestamos_por_usuario(Dni, Prestamos) :-
    findall(prestamo(IdPrestamo, Dni, Estado), prestamo(IdPrestamo, Dni, Estado), Prestamos).

calcular_balance(IdCuenta, Balance) :-
    findall(Monto, transaccion(_, IdCuenta, _, Monto), Egresos),
    findall(Monto, transaccion(_, _, IdCuenta, Monto), Ingresos),
    sum_list(Ingresos, TotalIngresos),
    sum_list(Egresos, TotalEgresos),
    Balance is TotalIngresos - TotalEgresos.

