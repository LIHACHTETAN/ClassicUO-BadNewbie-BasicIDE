# UO.Dist

ClassicUO • Runtime API

<!-- yoko-manual: 1 -->
<!-- yoko-locale: ko -->

X와 Y 절대 차이 중 큰 값으로 두 지점 사이의 타일 수를 계산합니다.

## 정확한 구문

```text
UO.Dist(Xfrom:Any, Yfrom:Any, Xto:Any, Yto:Any) -> Integer
```

## 매개변수

- `Xfrom` — 시작 X.
- `Yfrom` — 시작 Y.
- `Xto` — 목적지 X.
- `Yto` — 목적지 Y.

## 반환값

유효 좌표에서는 음수가 아닌 Integer 타일 수입니다. 0은 동일 XY, 1은 한 타일이며 성공 플래그가 아닙니다. 별도 비교 distance<=2가 1/True 또는 0/False를 만듭니다.

## 동작

- 패킷, 대기, 지도 로딩, 장애물, Z 또는 월드 검사가 없는 순수 계산입니다. 통행 경로를 찾거나 도착을 보장하지 않습니다. 같은 좌표계의 지점을 사용하며 우회 경로는 더 길 수 있습니다.
- 네 매개변수 모두 필요합니다. 문서 범위 0..65535의 Integer 월드 좌표를 전달하세요. Any는 범용 어댑터이며 물체 ID가 아닙니다. 기본값, 컨테이너 내부 좌표, 다섯 번째 Z, 단일 물체 오버로드는 없습니다.
- Max(Abs(Xto-Xfrom), Abs(Yto-Yfrom)). 지점을 바꿔도 같습니다. 유클리드 거리, 차이의 합, 장애물을 도는 걸음 수가 아닙니다.

### 내부 함수: 호출부터 결과까지

세 번째 예제는 일반 스크립트 함수로 알고리즘을 재현합니다. 엔진이 이 예제 함수를 내부적으로 호출한다는 뜻은 아닙니다.

#### 1. ExecuteStealthCompatibility

어댑터가 위치 0..3을 Xfrom,Yfrom,Xto,Yto 순서의 정수로 읽고 계산 함수를 호출합니다.

유효 좌표에서는 음수가 아닌 Integer 타일 수입니다. 0은 동일 XY, 1은 한 타일이며 성공 플래그가 아닙니다. 별도 비교 distance<=2가 1/True 또는 0/False를 만듭니다.

프로젝트 소스: `external/InjectionScript/src/InjectionScript/Runtime/InjectionApiUO.cs`; 함수 `ExecuteStealthCompatibility`.

#### 2. GetDistance

`GetDistance(int,int,int,int): dx=Math.Abs(x1-x2); dy=Math.Abs(y1-y2); return Math.Max(dx,dy).`

Max(Abs(Xto-Xfrom), Abs(Yto-Yfrom)). 지점을 바꿔도 같습니다. 유클리드 거리, 차이의 합, 장애물을 도는 걸음 수가 아닙니다.

프로젝트 소스: `external/InjectionScript/src/InjectionScript/Runtime/InjectionApiUO.cs`; 함수 `GetDistance`.

패킷, 대기, 지도 로딩, 장애물, Z 또는 월드 검사가 없는 순수 계산입니다. 통행 경로를 찾거나 도착을 보장하지 않습니다. 같은 좌표계의 지점을 사용하며 우회 경로는 더 길 수 있습니다.


## 예제

### 직접 계산

```vb
# 직접 계산
#
# X와 Y 절대 차이 중 큰 값으로 두 지점 사이의 타일 수를 계산합니다.
#
# 유효 좌표에서는 음수가 아닌 Integer 타일 수입니다. 0은 동일 XY, 1은 한 타일이며 성공 플래그가 아닙니다. 별도 비교 distance<=2가 1/True
# 또는 0/False를 만듭니다.

SUB Main()
    # (100,100)과 (103,104)의 절대 차이는 3과 4입니다. Main은 큰 값인 Integer 4를 반환합니다.
    # 유효 좌표에서는 음수가 아닌 Integer 타일 수입니다. 0은 동일 XY, 1은 한 타일이며 성공 플래그가 아닙니다. 별도 비교 distance<=2가 1/True
    # 또는 0/False를 만듭니다.
    # Max(Abs(Xto-Xfrom), Abs(Yto-Yfrom)). 지점을 바꿔도 같습니다. 유클리드 거리, 차이의 합, 장애물을 도는 걸음 수가 아닙니다.

    Return UO.Dist(100,100,103,104)
END SUB
```

**매개변수 및 실행 설명:**

- (100,100)과 (103,104)의 절대 차이는 3과 4입니다. Main은 큰 값인 Integer 4를 반환합니다.
- 유효 좌표에서는 음수가 아닌 Integer 타일 수입니다. 0은 동일 XY, 1은 한 타일이며 성공 플래그가 아닙니다. 별도 비교 distance<=2가 1/True 또는 0/False를 만듭니다.
- Max(Abs(Xto-Xfrom), Abs(Yto-Yfrom)). 지점을 바꿔도 같습니다. 유클리드 거리, 차이의 합, 장애물을 도는 걸음 수가 아닙니다.

### 결과 올바르게 판정

```vb
# 결과 올바르게 판정
#
# X와 Y 절대 차이 중 큰 값으로 두 지점 사이의 타일 수를 계산합니다.
#
# 유효 좌표에서는 음수가 아닌 Integer 타일 수입니다. 0은 동일 XY, 1은 한 타일이며 성공 플래그가 아닙니다. 별도 비교 distance<=2가 1/True
# 또는 0/False를 만듭니다.

SUB Main()
    # (100,100)과 (101,99)의 거리는 1이며 별도 비교 distance<=2는 True=1입니다. "1:1"의 첫 값은 거리이고 두 번째는 논리 결과입니다.
    # 유효 좌표에서는 음수가 아닌 Integer 타일 수입니다. 0은 동일 XY, 1은 한 타일이며 성공 플래그가 아닙니다. 별도 비교 distance<=2가 1/True
    # 또는 0/False를 만듭니다.
    # Max(Abs(Xto-Xfrom), Abs(Yto-Yfrom)). 지점을 바꿔도 같습니다. 유클리드 거리, 차이의 합, 장애물을 도는 걸음 수가 아닙니다.

    Dim distance=UO.Dist(100,100,101,99)
    Dim close=distance<=2
    Return CStr(distance) & ":" & CStr(close)
END SUB
```

**매개변수 및 실행 설명:**

- (100,100)과 (101,99)의 거리는 1이며 별도 비교 distance<=2는 True=1입니다. "1:1"의 첫 값은 거리이고 두 번째는 논리 결과입니다.
- 유효 좌표에서는 음수가 아닌 Integer 타일 수입니다. 0은 동일 XY, 1은 한 타일이며 성공 플래그가 아닙니다. 별도 비교 distance<=2가 1/True 또는 0/False를 만듭니다.
- Max(Abs(Xto-Xfrom), Abs(Yto-Yfrom)). 지점을 바꿔도 같습니다. 유클리드 거리, 차이의 합, 장애물을 도는 걸음 수가 아닙니다.

### 전체 스크립트 알고리즘

```vb
# 전체 스크립트 알고리즘
#
# X와 Y 절대 차이 중 큰 값으로 두 지점 사이의 타일 수를 계산합니다.
#
# 유효 좌표에서는 음수가 아닌 Integer 타일 수입니다. 0은 동일 XY, 1은 한 타일이며 성공 플래그가 아닙니다. 별도 비교 distance<=2가 1/True
# 또는 0/False를 만듭니다.

SUB Main()
    # UO.Dist와 RebuildTileDistance는 4, Main은 "4:4"를 반환합니다. 전체 도우미는 Abs 차이를 구해 큰 값을 반환합니다. 추가 API 명령이
    # 아닌 예제 코드입니다.
    # 유효 좌표에서는 음수가 아닌 Integer 타일 수입니다. 0은 동일 XY, 1은 한 타일이며 성공 플래그가 아닙니다. 별도 비교 distance<=2가 1/True
    # 또는 0/False를 만듭니다.
    # Max(Abs(Xto-Xfrom), Abs(Yto-Yfrom)). 지점을 바꿔도 같습니다. 유클리드 거리, 차이의 합, 장애물을 도는 걸음 수가 아닙니다.

    Dim actual=UO.Dist(100,100,103,104)
    Dim rebuilt=RebuildTileDistance(100,100,103,104)
    Return CStr(actual) & ":" & CStr(rebuilt)
END SUB

Function RebuildTileDistance(Xfrom, Yfrom, Xto, Yto) As Integer
    Dim dx = Abs(Xto-Xfrom)
    Dim dy = Abs(Yto-Yfrom)
    If dx>dy Then
        Return dx
    End If
    Return dy
End Function
```

**매개변수 및 실행 설명:**

- UO.Dist와 RebuildTileDistance는 4, Main은 "4:4"를 반환합니다. 전체 도우미는 Abs 차이를 구해 큰 값을 반환합니다. 추가 API 명령이 아닌 예제 코드입니다.
- 유효 좌표에서는 음수가 아닌 Integer 타일 수입니다. 0은 동일 XY, 1은 한 타일이며 성공 플래그가 아닙니다. 별도 비교 distance<=2가 1/True 또는 0/False를 만듭니다.
- Max(Abs(Xto-Xfrom), Abs(Yto-Yfrom)). 지점을 바꿔도 같습니다. 유클리드 거리, 차이의 합, 장애물을 도는 걸음 수가 아닙니다.
