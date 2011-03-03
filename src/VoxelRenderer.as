package {
	import flash.display.Sprite;
	import flash.display.Stage3D;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import no.doomsday.console.ConsoleUtil;
	
	public class VoxelRenderer extends Sprite {
		
		private var renderer:Renderer = new Renderer();
		private var mouse:Boolean = false;
		
		public function VoxelRenderer():void {
			//if (stage) init();
			//else addEventListener(Event.ADDED_TO_STAGE, init);
			addEventListener(Event.ADDED_TO_STAGE, init);
		}
		
		private function init(e:Event = null):void {
			removeEventListener(Event.ADDED_TO_STAGE, init);
			
			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.align = StageAlign.TOP_LEFT;
			
			var stage3D:Stage3D = stage.stage3Ds[0];
			//renderer.init(stage3D, 800, 600);
			//renderer.init(stage3D, 1280, 720);
			renderer.init(stage3D, stage.stageWidth, stage.stageHeight);
			renderer.addEventListener(Event.INIT, initRenderer);
			
			addChild(ConsoleUtil.instance);
			ConsoleUtil.show();
			
			stage.addEventListener(MouseEvent.MOUSE_DOWN, mouseDown);
		}
		
		private function mouseDown(e:MouseEvent):void {
			stage.addEventListener(MouseEvent.MOUSE_UP, mouseUp);
			mouse = true;
		}
		
		private function mouseUp(e:MouseEvent):void {
			stage.removeEventListener(MouseEvent.MOUSE_UP, mouseUp);
			mouse = false;
		}
		
		private function initRenderer(e:Event):void {
			addEventListener(Event.ENTER_FRAME, run);
		}
		
		private function run(e:Event):void {
			renderer.run(mouse, Math.max(0, Math.min(0.9999999999, mouseX/stage.stageWidth)));
		}
		
	}
	
}