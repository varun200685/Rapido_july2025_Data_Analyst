select * from rapido1.bookings;

-- (Easy) Find the total number of bookings for each Booking_Status.

SELECT count(*) as total_booking , Booking_Status
from rapido1.bookings
group by Booking_Status;

-- (Easy) Find the total Booking_Value for all rides where Booking_Status = 'Success'

select sum(booking_value), booking_status
from rapido1.bookings
group by Booking_Status
having Booking_Status = "success";

-- (Medium) Find the top 5 Pickup_Locations with the highest number of bookings.

select pickup_location, count(*) as total_booking
from rapido1.bookings
group by Pickup_Location
order by total_booking desc
limit 5;

-- (Medium) For each Vehicle_Type, find the average Ride_Distance and average Booking_Value, only for successful rides.

select vehicle_type,
	avg(ride_distance) as avg_ride_distance,
    avg(booking_value) as avg_booking_value
from rapido1.bookings
where booking_status = "success"
group by vehicle_type;

-- (Medium) Find the number of cancellations broken down by who canceled — customer vs driver — using Canceled_Rides_by_Customer and Canceled_Rides_by_Driver.

select count(booking_status) as total_ride,
	count(Canceled_Rides_by_Customer) as total_canceled_ride_by_customer,
    count(Canceled_Rides_by_Driver) as total_canceled_ride_by_driver,
    round(count(canceled_rides_by_customer)*100/count(booking_status),2) as customer,
    round(count(canceled_rides_by_Driver)*100/count(booking_status),2) as driver
from rapido1.bookings;
    
-- (Medium) Which Payment_Method generates the highest total revenue (Booking_Value), excluding nulls?

select payment_method, 
	count(payment_method) as count_of_payment,
    sum(Booking_Value) as total_revenue
from rapido1.bookings
where Payment_Method is not null
group by Payment_Method
order by total_revenue desc
limit 3;

-- (Hard) Find the customer (Customer_ID) with the second-highest total spend (sum of Booking_Value) across all their successful bookings.

select customer_id, total_spend, spend_rank
from(
	select customer_id, sum(booking_value) as total_spend,
    dense_rank() over(order by sum(booking_value) desc) as spend_rank
from rapido1.bookings
where Booking_Status = "success"
group by Customer_ID )as ranked
where spend_rank = 2;

-- (Hard) For each day (Date), calculate the cancellation rate = (canceled bookings / total bookings) * 100.

select date,
	count(booking_status) as total_booking,
    count(Canceled_Rides_by_Customer) as canceled_cust,
    count(Canceled_Rides_by_Driver) as canceld_driver,
    round((count(Canceled_Rides_by_Customer) + count(Canceled_Rides_by_Driver))*100/count(booking_status),2) as cancellation_rate
    from rapido1.bookings
    group by date;
    
    -- (Hard) Using a window function, rank Pickup_Locations by total revenue within each Vehicle_Type.

select vehicle_type, Pickup_Location, total_revenue, rank_location
from
	(select vehicle_type, pickup_location,
		sum(booking_value) as total_revenue,
        dense_rank() over(partition by Vehicle_Type order by sum(booking_value) desc) as rank_location
from rapido1.bookings
group by vehicle_type, Pickup_Location) as ranked
order by Vehicle_Type, rank_location;

-- (Interview-style) Find pairs of Pickup_Location → Drop_Location that appear more than 2 times, ordered by frequency descending.

select pickup_location, drop_location, count(*) as trip
from rapido1.bookings
group by Pickup_Location, Drop_Location
having trip > 2
order by trip desc