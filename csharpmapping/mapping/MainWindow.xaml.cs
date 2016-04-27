using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Windows;
using System.Windows.Controls;
using System.Windows.Data;
using System.Windows.Documents;
using System.Windows.Input;
using System.Windows.Media;
using System.Windows.Media.Imaging;
using System.Windows.Navigation;
using System.Windows.Shapes;
using Microsoft.Kinect;

namespace mapping
{
    /// <summary>
    /// Interaction logic for MainWindow.xaml
    /// </summary>
    public partial class MainWindow : Window
    {
        /// <summary>
        /// Active Kinect sensor
        /// </summary>
        private KinectSensor kinectSensor = null;
        /// <summary>
        /// Coordinate mapper to map one type of point to another
        /// </summary>
        private CoordinateMapper coordinateMapper = null;


        /// <summary>
        /// Intermediate storage for the color to depth mapping
        /// </summary>
        


        public MainWindow()
        {
            MLApp.MLApp matlab = new MLApp.MLApp();
            
            // Change to the directory where the function is located 
            matlab.Execute(@"cd D:\grad\courses\cs766\matlab-proj\cs766-project");

            // Define the output 
            object result = null;
            // TODO
            matlab.Feval("contruct3dImageScene", 0, out result);
            // Call the MATLAB function myfunc
            result = null;
            matlab.Feval("depthToColorPoint", 3, out result);

            // Display result 
            object[] res = result as object[];
            int[][] x = new int[3][];
            double[][] color_result = new double[2][];
            color_result[0] = new double[4];
            color_result[1] = new double[4];
            int x_count = 0;
            int y_count = 0;
            foreach (Array value in res)
            {
                y_count = 0;
                x[x_count] = new int[4];
                foreach(Double i in value)
                {
                    x[x_count][y_count] = (int)i;
                    y_count = y_count + 1;
                }
                x_count += 1;
                
            }
            this.kinectSensor = KinectSensor.GetDefault();
            // open the sensor
            this.kinectSensor.Open();
            System.Threading.Thread.Sleep(10000);
            this.coordinateMapper = this.kinectSensor.CoordinateMapper;
            CameraIntrinsics ci;
            ci = this.coordinateMapper.GetDepthCameraIntrinsics();
            Console.WriteLine("intristics: FX %f, FY %f, CX %f, CY %f", ci.FocalLengthX, ci.FocalLengthY, ci.PrincipalPointX, ci.PrincipalPointY);
            Console.WriteLine("Others: R2 %f, r4 %f, r6 %f", ci.RadialDistortionSecondOrder, ci.RadialDistortionFourthOrder, ci.RadialDistortionSixthOrder);
            DepthSpacePoint depthSpacePoint;
            ColorSpacePoint colorSpacePoint;
            for (int k = 0; k < 4; k++)
            {
                
                depthSpacePoint.X = (float)x[0][k];
                depthSpacePoint.Y = (float)x[1][k];
                UInt16 depth = (UInt16)x[2][k];
                colorSpacePoint = this.coordinateMapper.MapDepthPointToColorSpace(depthSpacePoint, depth);
                color_result[0][k] = colorSpacePoint.X;
                color_result[1][k] = colorSpacePoint.Y;
            }
            string xs = "";
            for (int i = 0; i < 4; i++)
            {
                xs += color_result[0][i].ToString();
                if (i != 3)
                {
                    xs += ";";
                }
                    
            }
            string ys = "";
            for (int i = 0; i < 4; i++)
            {
                ys += color_result[1][i].ToString();
                if (i != 3)
                {
                    ys += ";";
                }

            }
            // Define the output 
            result = null;
            //
            MLApp.MLApp matlab2 = new MLApp.MLApp();

            // Change to the directory where the function is located 
            matlab2.Execute(@"cd D:\grad\courses\cs766\matlab-proj\cs766-project");

            // Define the output 
            object result2 = null;

            // Call the MATLAB function myfunc
            // matlab.Feval("depthToColorPoint", 3, out result);
            matlab2.PutCharArray("str", "global", xs);
            matlab2.Feval("getRGBFromColor", 1, out result2, xs, ys);
        }
    }
}
