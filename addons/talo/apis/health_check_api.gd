class_name HealthCheckAPI extends TaloAPI
## An interface for communicating with the Talo Health Check API.
##
## This API is used to check if Talo can be reached by Continuity. You shouldn't need to use this API directly in your game.
##
## @tutorial: https://docs.trytalo.com/docs/godot/continuity

enum HealthCheckStatus {
	OK,
	FAILED,
	UNKNOWN
}

var _last_health_check_status = HealthCheckStatus.UNKNOWN

## Ping the Talo Health Check API to check if Talo can be reached.
func ping():
	client.make_request(HTTPClient.METHOD_GET, "", {}, [], false, [funcref(self, "ping_callback")])
	
func ping_callback(res):
	var success := true if res.status == 204 else false
	var failed_last_health_check := true if _last_health_check_status == HealthCheckStatus.FAILED else false

	if success:
		_last_health_check_status = HealthCheckStatus.OK
		if failed_last_health_check:
			Talo.emit_signal("connection_restored")
	else:
		_last_health_check_status = HealthCheckStatus.FAILED
		if not failed_last_health_check:
			Talo.emit_signal("connection_lost")

	return success

## Get the latest known health check status.
func get_last_status():
	return _last_health_check_status
