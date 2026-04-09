#!/usr/bin/env python3
"""
clean_image.py — 이미지 배경 제거 + 검정 라인아트 변환

손그림 이미지(회색/흰 배경)를 투명 배경 + 순수 검정 라인아트로 변환합니다.
캐릭터/카테고리 아이콘의 _clean 버전 생성 시 사용.

Usage:
  # 단일 파일
  python3 scripts/clean_image.py assets/images/category_images/car.png

  # 여러 파일
  python3 scripts/clean_image.py assets/images/category_images/*.png

  # 출력 파일명 지정
  python3 scripts/clean_image.py input.png -o output_clean.png

  # 밝기 임계값 조정 (기본 150, 높일수록 더 많이 제거)
  python3 scripts/clean_image.py input.png --threshold 170
"""

import argparse
import sys
from pathlib import Path

try:
    from PIL import Image
    import numpy as np
except ImportError:
    print("PIL/numpy 미설치. 아래 명령어로 설치하세요:")
    print("  pip3 install Pillow numpy")
    sys.exit(1)


def clean_image(
    input_path: Path,
    output_path: Path,
    threshold: int = 150,
    rotate: int = 0,
    canvas_size: int = 256,
    padding_ratio: float = 0.15,
) -> None:
    img = Image.open(input_path).convert('RGBA')

    # 회전 적용 (반시계 방향, expand=True로 잘림 방지)
    if rotate:
        img = img.rotate(rotate, expand=True)

    data = np.array(img, dtype=np.int32)

    r, g, b, a = data[:,:,0], data[:,:,1], data[:,:,2], data[:,:,3]

    # 밝은 픽셀(배경) → 투명
    is_light = (r >= threshold) & (g >= threshold) & (b >= threshold)
    data[is_light, 3] = 0

    # 남은 불투명 픽셀(라인아트) → 순수 검정
    is_dark = data[:,:,3] > 0
    data[is_dark, 0] = 0
    data[is_dark, 1] = 0
    data[is_dark, 2] = 0
    data[is_dark, 3] = 255

    result = Image.fromarray(data.astype(np.uint8), 'RGBA')

    # 정규화: 콘텐츠 크롭 → 정사각형 패딩 → 목표 크기로 리사이즈
    if canvas_size > 0:
        result = _normalize(result, canvas_size, padding_ratio)

    result.save(output_path)

    arr = np.array(result)
    total = arr.shape[0] * arr.shape[1]
    opaque = int((arr[:,:,3] == 255).sum())
    print(f"  {output_path.name}  ({result.size[0]}x{result.size[1]}, {opaque/total*100:.1f}% 라인아트)")


def _normalize(img: 'Image.Image', canvas_size: int, padding_ratio: float) -> 'Image.Image':
    """라인아트를 콘텐츠 기준으로 크롭하고 정사각형 캔버스에 균등 패딩으로 배치."""
    arr = np.array(img)
    alpha = arr[:,:,3]

    # 불투명 픽셀의 bounding box 계산
    rows = np.any(alpha > 0, axis=1)
    cols = np.any(alpha > 0, axis=0)
    if not rows.any():
        return img  # 라인아트 없으면 그대로 반환

    rmin, rmax = np.where(rows)[0][[0, -1]]
    cmin, cmax = np.where(cols)[0][[0, -1]]

    cropped = img.crop((cmin, rmin, cmax + 1, rmax + 1))

    # 정사각형 캔버스 크기 = 콘텐츠 최대변 + padding
    content_size = max(cropped.size)
    pad = int(content_size * padding_ratio)
    square = content_size + pad * 2

    canvas = Image.new('RGBA', (square, square), (0, 0, 0, 0))
    # 콘텐츠를 중앙에 배치
    offset_x = (square - cropped.size[0]) // 2
    offset_y = (square - cropped.size[1]) // 2
    canvas.paste(cropped, (offset_x, offset_y), cropped)

    # 목표 캔버스 크기로 리사이즈 (LANCZOS 안티앨리어싱)
    return canvas.resize((canvas_size, canvas_size), Image.LANCZOS)


def main():
    parser = argparse.ArgumentParser(description='이미지를 투명 배경 + 검정 라인아트로 변환')
    parser.add_argument('inputs', nargs='+', type=Path, help='입력 이미지 경로')
    parser.add_argument('-o', '--output', type=Path, help='출력 경로 (단일 파일일 때만 사용)')
    parser.add_argument('--threshold', type=int, default=150,
                        help='밝기 임계값 0-255 (기본 150, 높을수록 더 많이 제거)')
    parser.add_argument('--suffix', type=str, default='_clean',
                        help='출력 파일 접미사 (기본 _clean)')
    parser.add_argument('--rotate', type=int, default=0,
                        help='회전 각도 (반시계 방향, 예: 90, -90, 180)')
    parser.add_argument('--canvas-size', type=int, default=256,
                        help='출력 캔버스 크기 px (기본 256, 0이면 정규화 생략)')
    parser.add_argument('--padding', type=float, default=0.15,
                        help='콘텐츠 대비 패딩 비율 (기본 0.15 = 15%%)')
    args = parser.parse_args()

    if args.output and len(args.inputs) > 1:
        print("오류: -o 옵션은 입력 파일이 1개일 때만 사용 가능합니다.")
        sys.exit(1)

    for input_path in args.inputs:
        if not input_path.exists():
            print(f"파일 없음: {input_path}")
            continue

        if args.output:
            output_path = args.output
        else:
            output_path = input_path.with_stem(input_path.stem + args.suffix)

        clean_image(
            input_path, output_path,
            threshold=args.threshold,
            rotate=args.rotate,
            canvas_size=args.canvas_size,
            padding_ratio=args.padding,
        )


if __name__ == '__main__':
    main()
