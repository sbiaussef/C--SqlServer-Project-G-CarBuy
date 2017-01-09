using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Windows.Forms;

namespace Projet_Fin_Formation
{
    public partial class report : Form
    {
        public report()
        {
            InitializeComponent();
        }

        private void report_Load(object sender, EventArgs e)
        {
            CrystalReport1 cr1 = new CrystalReport1();
            crystalReportViewer1.ReportSource = cr1;
            crystalReportViewer1.Refresh();
        }
    }
}
