CREATE OR REPLACE FUNCTION get_relative_data(current_tick BIGINT)
RETURNS TABLE (calculated_timestamp TIMESTAMPTZ,
				tx_identifier VARCHAR,
				surface VARCHAR,
				signal_color VARCHAR,
				signal_name VARCHAR,
				signal_count INT
				) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        (NOW() - (current_tick - signals.tick) * INTERVAL '1 second' / 60) AS calculated_timestamp,
		signals.tx_identifier,
		signals.surface,
		signals.signal_color,
		signals.signal_name,
		signals.signal_count
    FROM signals;
END;
$$ LANGUAGE plpgsql;