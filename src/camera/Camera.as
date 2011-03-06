package camera {
	import flash.geom.Matrix3D;
	import flash.geom.Orientation3D;
	import flash.geom.Vector3D;
	import flash.utils.ByteArray;
	import flash.utils.IDataInput;
	import flash.utils.IDataOutput;
	public class Camera {
		public var defaultMoveAmount:Number = 5;
		public var defaultRotationAmount:Number = Math.PI/20;
		
		private var yaw:Number = 0;
		private var pitch:Number = 0;
		private var roll:Number = 0;
		
		public var matrix:Matrix3D = new Matrix3D();
		
		public function Camera(origin:Vector3D = null, rx:Number = 0, ry:Number = 0, rz:Number = 0) {
			//rotate(rx, ry, rz);
			//matrix.position = origin;
		}
		
		public function get o():Vector3D {
			return matrix.position;
		}
		public function set o(v:Vector3D):void {
			matrix.position = v;
		}
		public function get d():Vector3D {
			return matrix.deltaTransformVector(new Vector3D());
		}
		public function get x():Number {
			return matrix.position.x;
		}
		public function set x(v:Number):void {
			matrix.position = new Vector3D(v, o.y, o.z);
		}
		public function get y():Number {
			return matrix.position.y;
		}
		public function set y(v:Number):void {
			matrix.position = new Vector3D(o.x, v, o.z);
		}
		public function get z():Number {
			return matrix.position.z;
		}
		public function set z(v:Number):void {
			matrix.position = new Vector3D(o.x, o.y, v);
		}
		public function moveForward(amount:Number = NaN):void {
			if (isNaN(amount)) amount = defaultMoveAmount;
			//var dir:Vector3D = matrix.deltaTransformVector(new Vector3D(0, 0, amount));
			//matrix.appendTranslation(dir.x, dir.y, dir.z);
			matrix.appendTranslation(0, 0, amount);
		}
		public function moveBackward(amount:Number = NaN):void {
			if (isNaN(amount)) amount = defaultMoveAmount;
			//var dir:Vector3D = matrix.deltaTransformVector(new Vector3D(0, 0, -amount));
			//matrix.appendTranslation(dir.x, dir.y, dir.z);
			matrix.appendTranslation(0, 0, -amount);
		}
		public function moveLeft(amount:Number = NaN):void {
			if (isNaN(amount)) amount = defaultMoveAmount;
			//var dir:Vector3D = matrix.deltaTransformVector(new Vector3D(-amount, 0, 0));
			//matrix.appendTranslation(dir.x, dir.y, dir.z);
			matrix.appendTranslation(amount, 0, 0);
		}
		public function moveRight(amount:Number = NaN):void {
			if (isNaN(amount)) amount = defaultMoveAmount;
			//var dir:Vector3D = matrix.deltaTransformVector(new Vector3D(amount, 0, 0));
			//matrix.appendTranslation(dir.x, dir.y, dir.z);
			matrix.appendTranslation(-amount, 0, 0);
		}
		public function moveUp(amount:Number = NaN):void {
			if (isNaN(amount)) amount = defaultMoveAmount;
			//var dir:Vector3D = matrix.deltaTransformVector(new Vector3D(0.1, 0, 0));
			matrix.appendTranslation(0, amount, 0);
		}
		public function moveDown(amount:Number = NaN):void {
			if (isNaN(amount)) amount = defaultMoveAmount;
			//var dir:Vector3D = matrix.deltaTransformVector(new Vector3D(0.1, 0, 0));
			matrix.appendTranslation(0, -amount, 0);
		}
		public function rotateLeft(amount:Number = NaN):void {
			if (isNaN(amount)) amount = defaultRotationAmount;
			rotate(0, -amount, 0);
		}
		public function rotateRight(amount:Number = NaN):void {
			if (isNaN(amount)) amount = defaultRotationAmount;
			rotate(0, amount, 0);
		}
		public function rotateUp(amount:Number = NaN):void {
			if (isNaN(amount)) amount = defaultRotationAmount;
			rotate(-amount, 0, 0);
		}
		public function rotateDown(amount:Number = NaN):void {
			if (isNaN(amount)) amount = defaultRotationAmount;
			rotate(amount, 0, 0);
		}
		public function rotateCW(amount:Number = NaN):void {
			if (isNaN(amount)) amount = defaultRotationAmount;
			rotate(0, 0, -amount);
		}
		public function rotateCCW(amount:Number = NaN):void {
			if (isNaN(amount)) amount = defaultRotationAmount;
			rotate(0, 0, amount);
		}
		
		public function rotate(yawDelta:Number = 0, pitchDelta:Number = 0, rollDelta:Number = 0):void {
			yaw += yawDelta;
			pitch += pitchDelta;
			roll += rollDelta;
			var mv:Vector.<Vector3D> = matrix.decompose(Orientation3D.EULER_ANGLES);
			var mr:Vector3D = mv[1];
			mr.x = yaw;
			mr.y = pitch;
			mr.z = roll;
			matrix.recompose(mv, Orientation3D.EULER_ANGLES);
		}
		
		public function export(bytes:IDataOutput):void {
			var data:Vector.<Number> = matrix.rawData;
			for (var i:int = 0; i < data.length; i++) {
				bytes.writeDouble(data[i]);
			}
		}
		public function load(bytes:IDataInput):void {
			var data:Vector.<Number> = matrix.rawData;
			for (var i:int = 0; i < data.length; i++) {
				data[i] = bytes.readDouble();
			}
			matrix.rawData = data;
		}
		
		public function toString():String {
			var rd:Vector.<Number> = matrix.rawData;
			var mv:Vector.<Vector3D> = matrix.decompose(Orientation3D.EULER_ANGLES);
			var mr:Vector3D = mv[1];
			return rd[rd.length-4]+", "+rd[rd.length-3]+", "+rd[rd.length-2]+"), "+mr.x+", "+mr.y+", "+mr.z;
		}
		
		public function clone():Camera {
			var c:Camera = new Camera();
			c.matrix = matrix.clone();
			c.yaw = yaw;
			c.pitch = pitch;
			c.roll = roll;
			c.defaultMoveAmount = defaultMoveAmount;
			c.defaultRotationAmount = defaultRotationAmount;
			return c;
		}
	}
}