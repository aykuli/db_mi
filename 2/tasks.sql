-- 4.6
select t.passenger_name from tickets t 
  inner join ticket_flights tf on tf.ticket_no=t.ticket_no 
  inner join bookings b on b.book_ref=t.book_ref 
  where b.total_amount>70000 
    and tf.fare_conditions='Economy';

-- 4.7
select  tf.passenger_name,
        f.scheduled_departure, 
        f.scheduled_arrival, 
        f.departure_airport, 
        f.arrival_airport,
        ase.seat_no
        from flights f
  inner join (select t.passenger_id, t.passenger_name, tf0.flight_id from tickets t
                inner join ticket_flights tf0 on tf0.ticket_no=t.ticket_no
    ) tf
    on f.flight_id = tf.flight_id
  inner join ( select a.aircraft_code, s.seat_no from aircrafts a
                inner join seats s on s.aircraft_code = a.aircraft_code
    ) ase
    on ase.aircraft_code=f.aircraft_code
  limit 10;

  -- 4.9
  
