namespace BTSerialComTester
{
  partial class AboutBox
  {
    /// <summary>
    /// Required designer variable.
    /// </summary>
    private System.ComponentModel.IContainer components = null;

    /// <summary>
    /// Clean up any resources being used.
    /// </summary>
    protected override void Dispose(bool disposing)
    {
      if (disposing && (components != null))
      {
        components.Dispose();
      }
      base.Dispose(disposing);
    }

    #region Windows Form Designer generated code

    /// <summary>
    /// Required method for Designer support - do not modify
    /// the contents of this method with the code editor.
    /// </summary>
    private void InitializeComponent()
    {
		System.ComponentModel.ComponentResourceManager resources = new System.ComponentModel.ComponentResourceManager(typeof(AboutBox));
		this.labelVersion = new System.Windows.Forms.Label();
		this.labelProductName = new System.Windows.Forms.Label();
		this.labelCopyright = new System.Windows.Forms.Label();
		this.labelCompanyName = new System.Windows.Forms.Label();
		this.pictureBox1 = new System.Windows.Forms.PictureBox();
		this.txtLicense = new System.Windows.Forms.TextBox();
		this.button1 = new System.Windows.Forms.Button();
		this.txtDescription = new System.Windows.Forms.TextBox();
		((System.ComponentModel.ISupportInitialize)(this.pictureBox1)).BeginInit();
		this.SuspendLayout();
		// 
		// labelVersion
		// 
		this.labelVersion.AutoSize = true;
		this.labelVersion.Location = new System.Drawing.Point(123, 36);
		this.labelVersion.Margin = new System.Windows.Forms.Padding(6, 0, 3, 0);
		this.labelVersion.MaximumSize = new System.Drawing.Size(0, 17);
		this.labelVersion.Name = "labelVersion";
		this.labelVersion.Size = new System.Drawing.Size(42, 13);
		this.labelVersion.TabIndex = 21;
		this.labelVersion.Text = "Version";
		this.labelVersion.TextAlign = System.Drawing.ContentAlignment.MiddleLeft;
		// 
		// labelProductName
		// 
		this.labelProductName.AutoSize = true;
		this.labelProductName.Location = new System.Drawing.Point(123, 16);
		this.labelProductName.Margin = new System.Windows.Forms.Padding(6, 0, 3, 0);
		this.labelProductName.MaximumSize = new System.Drawing.Size(0, 17);
		this.labelProductName.Name = "labelProductName";
		this.labelProductName.Size = new System.Drawing.Size(75, 13);
		this.labelProductName.TabIndex = 28;
		this.labelProductName.Text = "Product Name";
		this.labelProductName.TextAlign = System.Drawing.ContentAlignment.MiddleLeft;
		// 
		// labelCopyright
		// 
		this.labelCopyright.AutoSize = true;
		this.labelCopyright.Location = new System.Drawing.Point(123, 56);
		this.labelCopyright.Margin = new System.Windows.Forms.Padding(6, 0, 3, 0);
		this.labelCopyright.MaximumSize = new System.Drawing.Size(0, 17);
		this.labelCopyright.Name = "labelCopyright";
		this.labelCopyright.Size = new System.Drawing.Size(51, 13);
		this.labelCopyright.TabIndex = 29;
		this.labelCopyright.Text = "Copyright";
		this.labelCopyright.TextAlign = System.Drawing.ContentAlignment.MiddleLeft;
		// 
		// labelCompanyName
		// 
		this.labelCompanyName.AutoSize = true;
		this.labelCompanyName.Location = new System.Drawing.Point(121, 76);
		this.labelCompanyName.Margin = new System.Windows.Forms.Padding(6, 0, 3, 0);
		this.labelCompanyName.MaximumSize = new System.Drawing.Size(0, 17);
		this.labelCompanyName.Name = "labelCompanyName";
		this.labelCompanyName.Size = new System.Drawing.Size(87, 13);
		this.labelCompanyName.TabIndex = 30;
		this.labelCompanyName.Text = "TL Systems, LLC";
		this.labelCompanyName.TextAlign = System.Drawing.ContentAlignment.MiddleLeft;
		// 
		// pictureBox1
		// 
		this.pictureBox1.Image = ((System.Drawing.Image)(resources.GetObject("pictureBox1.Image")));
		this.pictureBox1.Location = new System.Drawing.Point(12, 12);
		this.pictureBox1.Name = "pictureBox1";
		this.pictureBox1.Size = new System.Drawing.Size(102, 194);
		this.pictureBox1.SizeMode = System.Windows.Forms.PictureBoxSizeMode.CenterImage;
		this.pictureBox1.TabIndex = 32;
		this.pictureBox1.TabStop = false;
		// 
		// txtLicense
		// 
		this.txtLicense.BackColor = System.Drawing.Color.PowderBlue;
		this.txtLicense.BorderStyle = System.Windows.Forms.BorderStyle.None;
		this.txtLicense.Location = new System.Drawing.Point(13, 232);
		this.txtLicense.Margin = new System.Windows.Forms.Padding(6, 3, 3, 3);
		this.txtLicense.Multiline = true;
		this.txtLicense.Name = "txtLicense";
		this.txtLicense.ReadOnly = true;
		this.txtLicense.Size = new System.Drawing.Size(424, 197);
		this.txtLicense.TabIndex = 33;
		this.txtLicense.TabStop = false;
		this.txtLicense.Tag = "License";
		this.txtLicense.TextAlign = System.Windows.Forms.HorizontalAlignment.Center;
		// 
		// button1
		// 
		this.button1.Anchor = ((System.Windows.Forms.AnchorStyles)((System.Windows.Forms.AnchorStyles.Bottom | System.Windows.Forms.AnchorStyles.Right)));
		this.button1.DialogResult = System.Windows.Forms.DialogResult.Cancel;
		this.button1.Location = new System.Drawing.Point(358, 443);
		this.button1.Name = "button1";
		this.button1.Size = new System.Drawing.Size(75, 22);
		this.button1.TabIndex = 34;
		this.button1.Text = "&OK";
		// 
		// txtDescription
		// 
		this.txtDescription.BorderStyle = System.Windows.Forms.BorderStyle.None;
		this.txtDescription.Location = new System.Drawing.Point(123, 104);
		this.txtDescription.Margin = new System.Windows.Forms.Padding(6, 3, 3, 3);
		this.txtDescription.Multiline = true;
		this.txtDescription.Name = "txtDescription";
		this.txtDescription.ReadOnly = true;
		this.txtDescription.Size = new System.Drawing.Size(314, 102);
		this.txtDescription.TabIndex = 36;
		this.txtDescription.TabStop = false;
		this.txtDescription.Tag = "";
		this.txtDescription.Text = "Description";
		// 
		// AboutBox
		// 
		this.AutoScaleDimensions = new System.Drawing.SizeF(6F, 13F);
		this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
		this.ClientSize = new System.Drawing.Size(453, 477);
		this.Controls.Add(this.txtDescription);
		this.Controls.Add(this.button1);
		this.Controls.Add(this.txtLicense);
		this.Controls.Add(this.pictureBox1);
		this.Controls.Add(this.labelCompanyName);
		this.Controls.Add(this.labelCopyright);
		this.Controls.Add(this.labelProductName);
		this.Controls.Add(this.labelVersion);
		this.FormBorderStyle = System.Windows.Forms.FormBorderStyle.FixedDialog;
		this.MaximizeBox = false;
		this.MinimizeBox = false;
		this.Name = "AboutBox";
		this.Padding = new System.Windows.Forms.Padding(9);
		this.ShowIcon = false;
		this.ShowInTaskbar = false;
		this.StartPosition = System.Windows.Forms.FormStartPosition.CenterParent;
		((System.ComponentModel.ISupportInitialize)(this.pictureBox1)).EndInit();
		this.ResumeLayout(false);
		this.PerformLayout();

    }

    #endregion

	private System.Windows.Forms.Label labelVersion;
	private System.Windows.Forms.Label labelProductName;
	private System.Windows.Forms.Label labelCopyright;
	private System.Windows.Forms.Label labelCompanyName;
	private System.Windows.Forms.PictureBox pictureBox1;
	private System.Windows.Forms.TextBox txtLicense;
	private System.Windows.Forms.Button button1;
	private System.Windows.Forms.TextBox txtDescription;
  }
}
