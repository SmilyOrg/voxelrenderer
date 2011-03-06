package {
	import camera.CameraController;
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.display.Stage3D;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.geom.Matrix3D;
	import flash.geom.Point;
	import flash.system.System;
	import flash.ui.Keyboard;
	import no.doomsday.console.ConsoleUtil;
	
	public class VoxelRenderer extends Sprite {
		[Embed(source='assets/terrain.png')]
		private var Texture:Class;
		
		private var renderer:Renderer = new Renderer();
		//private var mouse:Boolean = false;
		
		private var cc:CameraController = new CameraController();
		private var mouse:Boolean = false;
		private var lookOffset:Point = new Point();
		
		public function VoxelRenderer():void {
			//if (stage) init();
			//else addEventListener(Event.ADDED_TO_STAGE, init);
			addEventListener(Event.ADDED_TO_STAGE, init);
		}
		
		private function init(e:Event = null):void {
			removeEventListener(Event.ADDED_TO_STAGE, init);
			
			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.align = StageAlign.TOP_LEFT;
			
			renderer.textureImage = (new Texture() as Bitmap).bitmapData;
			
			var stage3D:Stage3D = stage.stage3Ds[0];
			//renderer.init(stage3D, 800, 600);
			//renderer.init(stage3D, 1280, 720);
			renderer.init(stage3D, stage.stageWidth, stage.stageHeight);
			renderer.addEventListener(Event.INIT, initRenderer);
			
			addChild(ConsoleUtil.instance);
			ConsoleUtil.show();
			
			//stage.addEventListener(MouseEvent.MOUSE_DOWN, mouseDown);
		}
		
		private function mouseDown(e:MouseEvent):void {
			stage.addEventListener(MouseEvent.MOUSE_UP, mouseUp);
			
			lookOffset.x = stage.mouseX;
			lookOffset.y = stage.mouseY;
			
			mouse = true;
		}
		private function mouseUp(e:MouseEvent):void {
			stage.removeEventListener(MouseEvent.MOUSE_UP, mouseUp);
			
			mouse = false;
		}
		
		private function initRenderer(e:Event):void {
			addEventListener(Event.ENTER_FRAME, run);
			
			cc.init(stage, stage);
			
			//renderer.camera = cc.cam.matrix;
			//renderer.camera = camera.matrix;
		}
		
		private function run(e:Event):void {
			cc.run();
			renderer.camera = cc.cam.matrix.clone();
			renderer.run(mouse, Math.max(0, Math.min(0.9999999999, mouseX/stage.stageWidth)));
			//renderer.run();
		}
		
	}
	
}