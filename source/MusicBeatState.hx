package;

import Conductor.BPMChangeEvent;
import flixel.FlxG;
import flixel.addons.ui.FlxUIState;
import flixel.math.FlxRect;
import flixel.util.FlxTimer;
import flixel.addons.transition.FlxTransitionableState;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.FlxSprite;
import flixel.util.FlxColor;
import flixel.util.FlxGradient;
import flixel.FlxState;
import flixel.FlxBasic;
import openfl.Lib;
import flixel.system.scaleModes.RatioScaleMode;
#if mobileC
import flixel.FlxCamera;
import flixel.input.actions.FlxActionInput;
import ui.FlxVirtualPad;
#end
class MusicBeatState extends FlxUIState
{
	private var lastBeat:Float = 0;
	private var lastStep:Float = 0;

	private var curStep:Int = 0;
	private var curBeat:Int = 0;

	public var curDecStep:Float = 0;
	public var curDecBeat:Float = 0;

	private var controls(get, never):Controls;

	inline function get_controls():Controls
		return PlayerSettings.player1.controls;

	#if mobileC
		var _virtualpad:FlxVirtualPad;

		var trackedinputs:Array<FlxActionInput> = [];

		// adding virtualpad to state
		public function addVirtualPad(?DPad:FlxDPadMode, ?Action:FlxActionMode) {
			_virtualpad = new FlxVirtualPad(DPad, Action);
			_virtualpad.alpha = 0.75;
			var padcam = new FlxCamera();
			FlxG.cameras.add(padcam);
			padcam.bgColor.alpha = 0;
			_virtualpad.cameras = [padcam];
			add(_virtualpad);
			controls.setVirtualPad(_virtualpad, DPad, Action);
			trackedinputs = controls.trackedinputs;
			controls.trackedinputs = [];

			#if android
			controls.addAndroidBack();
			#end
		}

		override function destroy() {
			controls.removeFlxInput(trackedinputs);

			super.destroy();
		}
		#else
		public function addVirtualPad(?DPad, ?Action){};
		#end
	override function create() {

		super.create();

	}

	#if (VIDEOS_ALLOWED && windows)
	override public function onFocus():Void
	{
		FlxVideo.onFocus();
		super.onFocus();
	}

	override public function onFocusLost():Void
	{
		FlxVideo.onFocusLost();
		super.onFocusLost();
	}
	#end

	override function update(elapsed:Float)
	{
		//everyStep();
		var oldStep:Int = curStep;

		updateCurStep();
		updateBeat();

		if (oldStep != curStep && curStep > 0)
			stepHit();

		super.update(elapsed);
	}

	private function updateBeat():Void
	{
		curBeat = Math.floor(curStep / 4);
		curDecBeat = curDecStep/4;
	}

	private function updateCurStep():Void
	{
		var lastChange:BPMChangeEvent = {
			stepTime: 0,
			songTime: 0,
			bpm: 0
		}
		for (i in 0...Conductor.bpmChangeMap.length)
		{
			if (Conductor.songPosition >= Conductor.bpmChangeMap[i].songTime)
				lastChange = Conductor.bpmChangeMap[i];
		}

		var shit = ((Conductor.songPosition - ClientPrefs.noteOffset) - lastChange.songTime) / Conductor.stepCrochet;
		curDecStep = lastChange.stepTime + shit;
		curStep = lastChange.stepTime + Math.floor(shit);
	}

	public static function switchState(nextState:FlxState) {
		FlxG.switchState(nextState); // just because im too lazy to goto every instance of switchState and change it to a FlxG call
	}

	public static function resetState() {
		FlxG.resetState();
	}

	public static function getState():MusicBeatState {
		var curState:Dynamic = FlxG.state;
		var leState:MusicBeatState = curState;
		return leState;
	}

	public function stepHit():Void
	{
		if (curStep % 4 == 0)
			beatHit();
	}

	public function beatHit():Void
	{
		//do literally nothing dumbass
	}
}
