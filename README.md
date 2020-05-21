# ARKit



SCNGeometry : 화면에 보여주는 객체로 크기를 설정

SCNMaterial : geometry가 렌더링 될때 표면을 정의하는 객체

SCNNode : Geometry를 좌표 공간에서 위치 및 방향, 회전 또는 에니메이션을 나타내는 객체 실제 씬에 추가 할수있다

SCNKit에서 사용되는 길이의 단위는 미터로 사용 

![](https://img1.daumcdn.net/thumb/R1280x0/?scode=mtistory2&fname=https%3A%2F%2Fk.kakaocdn.net%2Fdn%2Fom7v2%2FbtqvrCIRSKY%2FCw1VFXkRSHvoUSDIZuUkU1%2Fimg.png)

PhysicsBody : Node에 물리적인 성질을 가지게 함

dampping : 물체가 운동 중 때 (움직일 때)  운동 감소 지수 

simd_float4x4 : 4x4 좌표계로 노드의 좌표, 스케일, 회전, 요소를 포함하고 있다. 

SCNNode.worldFront : 좌표계가 반대로 된다.

func matrix_multiply(_ __x: simd_float4x4, _ __y: simd_float4x4) -> simd_float4x4 

앞 좌표에 뒷자표만큼 더한다?
