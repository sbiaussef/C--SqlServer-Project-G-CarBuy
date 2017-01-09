using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using System.Windows.Forms;
using System.Data.SqlClient;
using System.Data;
namespace Projet_Fin_Formation
{
    static class Program
    {
        public static SqlConnection cn = new SqlConnection(@"Data Source=USSEF-PC;Initial Catalog=gest_voit;Integrated Security=True");
        public static SqlCommand cmd = cn.CreateCommand();
        public static SqlDataReader dr;
        public static DataTable dt = new DataTable();
        /// <summary>
        /// Point d'entrée principal de l'application.
        /// </summary>
        [STAThread]
        static void Main()
        {
            Application.EnableVisualStyles();
            Application.SetCompatibleTextRenderingDefault(false);
            Application.Run(new Form1());
        }
    }
}
