using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Windows.Forms;
using System.Data.SqlClient;

namespace Projet_Fin_Formation
{
    public partial class Form1 : Form
    {
        public Form1()
        {
            InitializeComponent();
        }
       public int tst ;
        private void Form1_Load(object sender, EventArgs e)
        {
            Program.cn.Open();
            Program.cmd = new SqlCommand("select day(getdate())", Program.cn);
            tst = (int)Program.cmd.ExecuteScalar();

            if (tst != 1)
            {
                button1.Enabled = true;
                comboBox1.Enabled = true;
                comboBox2.Enabled = true;
            }
            else
            {
                button1.Enabled = false;
                comboBox1.Enabled = false;
                comboBox2.Enabled = false;
            }

            Program.cmd = new SqlCommand("select sum(beneficeTotal) from v2", Program.cn);
           //float help = (float)Program.cmd.ExecuteScalar();
            Program.dr=Program.cmd.ExecuteReader();
                while(Program.dr.Read())
                {
                    label1.Text = "La benefice de la mois actuelle est : "+Program.dr[0].ToString();
                }
                Program.dr.Close();
            Program.cmd.CommandText = "sp_magasin";
            Program.cmd.Connection = Program.cn;
            Program.cmd.CommandType = CommandType.StoredProcedure;
            try
            {
                Program.dr=Program.cmd.ExecuteReader();
                Program.dt.Load(Program.dr);
                dataGridView1.DataSource = Program.dt;
                
            }
            catch (SqlException sx) { MessageBox.Show(sx.Message); }
            finally { Program.cn.Close(); }
            
        }

        private void button1_Click(object sender, EventArgs e)
        {
            Program.cn.Open();
            Program.cmd.Parameters.Clear();
            Program.cmd.Parameters.Add("@prctg1", SqlDbType.Int).Value = comboBox1.SelectedItem;
            Program.cmd.Parameters.Add("@prctg2", SqlDbType.Int).Value = comboBox2.SelectedItem;
            Program.cmd.CommandText = "sp_batch";
            Program.cmd.Connection = Program.cn;
            Program.cmd.CommandType = CommandType.StoredProcedure;
            try
            {
                Program.cmd.ExecuteNonQuery();
                MessageBox.Show("Operation succe", "Confirmer", MessageBoxButtons.OK, MessageBoxIcon.Information);
            }
            catch (SqlException sx) { MessageBox.Show(sx.Message); }
            finally { Program.cn.Close(); }
            button1.Enabled = false;
            comboBox1.Enabled = false;
            comboBox2.Enabled = false;
        }

        private void button3_Click(object sender, EventArgs e)
        {
            Application.Exit();
        }

        private void button2_Click(object sender, EventArgs e)
        {
            new report().Show();
        }
    }
}
