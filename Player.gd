extends RigidBody3D

## How much vertical force to apply when moving.
@export_range(750.00, 3000.00) var thrust: float = 1000.00

@export var torque: float = 100.00

@onready var explosion_audio: AudioStreamPlayer = $ExplosionAudio
@onready var success_audio: AudioStreamPlayer = $SuccessAudio
@onready var rocket_audio: AudioStreamPlayer3D = $RocketAudio
@onready var booster_particles: GPUParticles3D = $BoosterParticles
@onready var booster_particles_r: GPUParticles3D = $BoosterParticlesR
@onready var booster_particles_l: GPUParticles3D = $BoosterParticlesL
@onready var explosion_particles: GPUParticles3D = $ExplosionParticles
@onready var success_particles: GPUParticles3D = $SuccessParticles


var is_transitioning: bool = false

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Input.is_action_pressed("boost"):
		apply_central_force(basis.y * delta * thrust)
		booster_particles.emitting = true
		if rocket_audio.playing == false:
			rocket_audio.play()
	else:
		rocket_audio.stop()
		booster_particles.emitting = false
		
	if Input.is_action_pressed("rotate_left"):
		apply_torque(Vector3(0, 0, torque) * delta)
		booster_particles_r.emitting = true
	else:
		booster_particles_r.emitting = false
	
	if Input.is_action_pressed("rotate_right"):
		apply_torque(Vector3(0, 0, -torque) * delta)
		booster_particles_l.emitting = true
	else:
		booster_particles_l.emitting = false


func _on_body_entered(body: Node) -> void:
	if is_transitioning == false:
		if "Goal" in body.get_groups():
			complete_level(body.file_path)
		if "Hazard" in body.get_groups():
			crash_sequence()


func crash_sequence() -> void:
	print("CRASHED")
	rocket_audio.stop()
	explosion_audio.play()
	booster_particles.emitting = false
	booster_particles_l.emitting = false
	booster_particles_r.emitting = false
	explosion_particles.emitting = true
	set_process(false)
	is_transitioning = true
	await get_tree().create_timer(2.5).timeout
	get_tree().reload_current_scene()
	
func complete_level(next_level) -> void:
	print("SUCCESS")
	rocket_audio.stop()
	success_audio.play()
	booster_particles.emitting = false
	success_particles.emitting = true
	set_process(false)
	is_transitioning = true
	await get_tree().create_timer(1.5).timeout
	get_tree().change_scene_to_file(next_level)
