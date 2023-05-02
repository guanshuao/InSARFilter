# 这个脚本将读取filtered_test.int文件，计算干涉图的相位，然后将相位数据转换为彩色图像并将其保存为GeoTIFF文件。
# 要运行这个脚本，您需要在命令行中提供文件名、宽度和高度作为参数。例如：
# python gen_tif.py filtered_test.int 2551 2108


import numpy as np
import sys
import rasterio
import matplotlib.pyplot as plt
from rasterio.transform import Affine


def read_interferogram(file_name, width, height):
    # 从二进制文件中读取干涉图数据并将其重新整形为二维矩阵
    data = np.fromfile(file_name, dtype=np.complex64).reshape((height, width))
    return data


def save_phase_tif(phase_data, output_file):
    # 创建仿射变换矩阵，将地理坐标系映射到像素坐标系
    transform = Affine.translation(0.5, 0.5) * Affine.scale(1, -1)

    # 打开GeoTIFF文件并设置属性
    with rasterio.open(
            output_file,
            'w',
            driver='GTiff',
            height=phase_data.shape[0],
            width=phase_data.shape[1],
            count=3,  # 设置通道数为3（红、绿、蓝）
            dtype=phase_data.dtype,
            crs='+proj=latlong',
            transform=transform,
    ) as dst:
        # 写入每个颜色通道
        for k in range(3):
            dst.write(phase_data[:, :, k], k + 1)


def main(file_name, width, height):
    # 读取干涉图数据
    interferogram = read_interferogram(file_name, width, height)
    # 计算相位数据
    phase_data = np.angle(interferogram)

    # 使用HSV颜色映射将相位数据转换为彩色数据
    cmap = plt.get_cmap('hsv')
    phase_color = cmap((phase_data + np.pi) / (2 * np.pi))
    phase_color_uint8 = (phase_color * 255).astype(np.uint8)

    # 生成输出文件名
    output_file = file_name.replace('.int', '.int.tif')
    # 将彩色相位数据保存为GeoTIFF文件
    save_phase_tif(phase_color_uint8, output_file)


if __name__ == "__main__":
    if len(sys.argv) > 3:
        file_name = sys.argv[1]
        width = int(sys.argv[2])
        height = int(sys.argv[3])
    else:
        print("Usage: python gen_tif.py <file_name> <width> <height>")
        sys.exit(1)

    main(file_name, width, height)
