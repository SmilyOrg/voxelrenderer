package camera {
	import flash.display.InteractiveObject;
	import flash.display.Stage;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.geom.Matrix3D;
	import flash.geom.Point;
	import flash.geom.Vector3D;
	import flash.ui.Keyboard;
	public class CameraController {
		
		public var cam:Camera = new Camera();
		
		private var target:InteractiveObject;
		private var stage:Stage;
		
		private var targetMatrix:Matrix3D = new Matrix3D();
		private var p:Vector3D = new Vector3D();
		private var v:Vector3D = new Vector3D();
		
		private var lookOffset:Point = new Point();
		
		private var mouseView:Boolean = false;
		private var forward:Boolean = false;
		private var backward:Boolean = false;
		private var left:Boolean = false;
		private var right:Boolean = false;
		private var up:Boolean = false;
		private var down:Boolean = false;
		private var moveSpeed:Number = 0.01;
		
		private var yaw:Number = 0;
		private var pitch:Number = 0;
		
		public function CameraController() {}
		public function init(target:InteractiveObject, stage:Stage):void {
			this.target = target;
			this.stage = stage;
			
			target.addEventListener(MouseEvent.MOUSE_DOWN, mouseDown);
			target.addEventListener(KeyboardEvent.KEY_DOWN, keyDown);
			target.addEventListener(KeyboardEvent.KEY_UP, keyUp);
		}
		
		private function keyDown(e:KeyboardEvent):void {
			//var c:Camera = cam;
			//c.defaultMoveAmount = e.shiftKey ? 10 : (e.ctrlKey ? 0.1 : 1);
			switch (e.keyCode) {
				case 87: case Keyboard.UP: forward = true; break;
				case 83: case Keyboard.DOWN: backward = true; break;
				case 65: case Keyboard.LEFT: left = true; break;
				case 68: case Keyboard.RIGHT: right = true; break;
				case 69: case Keyboard.SPACE: up = true; break; // E
				case 81: case Keyboard.CONTROL: down = true; break; // Q
				case Keyboard.SHIFT: moveSpeed = 0.1; break;
			}
		}
		private function keyUp(e:KeyboardEvent):void {
			switch (e.keyCode) {
				case 87: case Keyboard.UP: forward = false; break;
				case 83: case Keyboard.DOWN: backward = false; break;
				case 65: case Keyboard.LEFT: left = false; break;
				case 68: case Keyboard.RIGHT: right = false; break;
				case 69: case Keyboard.SPACE: up = false; break; // E
				case 81: case Keyboard.CONTROL: down = false; break; // Q
				case Keyboard.SHIFT: moveSpeed = 0.01; break;
			}
		}
		
		private function mouseDown(e:MouseEvent):void {
			stage.addEventListener(MouseEvent.MOUSE_UP, mouseUp);
			//stage.addEventListener(MouseEvent.MOUSE_MOVE, mouseMove);
			
			lookOffset.x = target.mouseX;
			lookOffset.y = target.mouseY;
			
			mouseView = true;
		}
		
		private function mouseMove(e:MouseEvent):void {
			var dx:Number = target.mouseX-lookOffset.x;
			var dy:Number = target.mouseY-lookOffset.y;
			
			//targetMatrix.appendRotation(dx*0.2, Vector3D.Y_AXIS);
			//targetMatrix.appendRotation(dy*0.2, Vector3D.X_AXIS);
			lookOffset.x = target.mouseX; lookOffset.y = target.mouseY;
		}
		
		private function mouseUp(e:MouseEvent):void {
			stage.removeEventListener(MouseEvent.MOUSE_UP, mouseUp);
			//stage.removeEventListener(MouseEvent.MOUSE_MOVE, mouseMove);
			
			mouseView = false;
		}
		
		public function run():void {
			if (forward) v.z += moveSpeed;
			if (backward) v.z -= moveSpeed;
			if (left) v.x += moveSpeed;
			if (right) v.x -= moveSpeed;
			if (up) v.y -= moveSpeed;
			if (down) v.y += moveSpeed;
			
			
			if (mouseView) {
				var dx:Number = (target.mouseX-stage.stageWidth/2)*360*0.00002;
				var dy:Number = (target.mouseY-stage.stageHeight/2)*360*0.00002;
				
				yaw += dx;
				pitch += dy;
			}
			v.x *= 0.9;
			v.y *= 0.9;
			v.z *= 0.9;
			
			var rotation:Matrix3D = new Matrix3D();
			rotation.appendRotation(-pitch, Vector3D.X_AXIS);
			rotation.appendRotation(-yaw, Vector3D.Y_AXIS);
			var dv:Vector3D = rotation.transformVector(v);
			p.incrementBy(dv);
			
			targetMatrix.identity();
			targetMatrix.appendTranslation(p.x, p.y, p.z);
			targetMatrix.appendRotation(yaw, Vector3D.Y_AXIS);
			targetMatrix.appendRotation(pitch, Vector3D.X_AXIS);
			
			cam.matrix = targetMatrix.clone();
		}
		
		
	}

}