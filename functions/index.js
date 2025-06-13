const functions = require('firebase-functions');
const admin = require('firebase-admin');
const nodemailer = require('nodemailer');
const cors = require('cors')({origin: true});

admin.initializeApp();

// Email configuration - You'll need to set these in Firebase Functions config
const EMAIL_CONFIG = {
  service: 'gmail',
  auth: {
    user: 'rathin007008@gmail.com', // Your Gmail
    pass: functions.config().gmail?.password || process.env.GMAIL_APP_PASSWORD // App password
  }
};

// Create transporter
const transporter = nodemailer.createTransporter(EMAIL_CONFIG);

// Cloud Function to send contact form emails
exports.sendContactEmail = functions.https.onCall(async (data, context) => {
  try {
    console.log('Received contact form data:', data);
    
    // Validate required fields
    if (!data.name || !data.email || !data.subject || !data.message) {
      throw new functions.https.HttpsError('invalid-argument', 'Missing required fields');
    }

    // Create comprehensive JSON data
    const contactData = {
      ...data,
      timestamp: new Date().toISOString(),
      messageId: `msg_${Date.now()}_${Math.random().toString(36).substr(2, 9)}`,
      receivedAt: admin.firestore.Timestamp.now(),
      platform: data.platform || 'Unknown',
      userAgent: data.userAgent || 'Unknown',
      deviceInfo: data.deviceInfo || {},
      ipAddress: context.rawRequest?.ip || 'Unknown'
    };

    // Save to Firestore for backup
    await admin.firestore().collection('contacts').add(contactData);

    // Create email content
    const emailContent = createEmailContent(contactData);
    
    // Send email
    const mailOptions = {
      from: `"Portfolio Contact Form" <${EMAIL_CONFIG.auth.user}>`,
      to: 'rathin007008@gmail.com',
      subject: `Portfolio Contact: ${data.subject}`,
      html: emailContent.html,
      text: emailContent.text
    };

    await transporter.sendMail(mailOptions);
    
    console.log('Email sent successfully to rathin007008@gmail.com');
    
    return {
      success: true,
      messageId: contactData.messageId,
      message: 'Email sent successfully'
    };

  } catch (error) {
    console.error('Error sending email:', error);
    throw new functions.https.HttpsError('internal', 'Failed to send email: ' + error.message);
  }
});

// HTTP endpoint for direct API calls
exports.sendContactEmailHTTP = functions.https.onRequest((req, res) => {
  return cors(req, res, async () => {
    if (req.method !== 'POST') {
      return res.status(405).json({error: 'Method not allowed'});
    }

    try {
      const data = req.body;
      
      // Validate required fields
      if (!data.name || !data.email || !data.subject || !data.message) {
        return res.status(400).json({error: 'Missing required fields'});
      }

      // Create comprehensive JSON data
      const contactData = {
        ...data,
        timestamp: new Date().toISOString(),
        messageId: `msg_${Date.now()}_${Math.random().toString(36).substr(2, 9)}`,
        receivedAt: admin.firestore.Timestamp.now(),
        platform: data.platform || 'Unknown',
        userAgent: req.get('User-Agent') || 'Unknown',
        deviceInfo: data.deviceInfo || {},
        ipAddress: req.ip || req.connection.remoteAddress || 'Unknown'
      };

      // Save to Firestore
      await admin.firestore().collection('contacts').add(contactData);

      // Create email content
      const emailContent = createEmailContent(contactData);
      
      // Send email
      const mailOptions = {
        from: `"Portfolio Contact Form" <${EMAIL_CONFIG.auth.user}>`,
        to: 'rathin007008@gmail.com',
        subject: `Portfolio Contact: ${data.subject}`,
        html: emailContent.html,
        text: emailContent.text
      };

      await transporter.sendMail(mailOptions);
      
      console.log('Email sent successfully via HTTP endpoint');
      
      return res.status(200).json({
        success: true,
        messageId: contactData.messageId,
        message: 'Email sent successfully'
      });

    } catch (error) {
      console.error('Error in HTTP endpoint:', error);
      return res.status(500).json({error: 'Failed to send email: ' + error.message});
    }
  });
});

// Function to create email content
function createEmailContent(contactData) {
  const jsonData = JSON.stringify(contactData, null, 2);
  
  const html = `
    <!DOCTYPE html>
    <html>
    <head>
      <style>
        body { font-family: Arial, sans-serif; line-height: 1.6; color: #333; }
        .container { max-width: 600px; margin: 0 auto; padding: 20px; }
        .header { background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); color: white; padding: 20px; border-radius: 8px 8px 0 0; }
        .content { background: #f9f9f9; padding: 20px; border-radius: 0 0 8px 8px; }
        .section { margin-bottom: 20px; }
        .label { font-weight: bold; color: #555; }
        .value { margin-left: 10px; }
        .json-data { background: #2d3748; color: #e2e8f0; padding: 15px; border-radius: 5px; font-family: monospace; font-size: 12px; overflow-x: auto; }
        .footer { text-align: center; margin-top: 20px; color: #666; font-size: 12px; }
      </style>
    </head>
    <body>
      <div class="container">
        <div class="header">
          <h2>🚀 New Portfolio Contact Form Submission</h2>
          <p>You have received a new message through your Flutter portfolio!</p>
        </div>
        
        <div class="content">
          <div class="section">
            <h3>📧 Contact Information</h3>
            <p><span class="label">Name:</span><span class="value">${contactData.name}</span></p>
            <p><span class="label">Email:</span><span class="value">${contactData.email}</span></p>
            <p><span class="label">Subject:</span><span class="value">${contactData.subject}</span></p>
          </div>
          
          <div class="section">
            <h3>💬 Message</h3>
            <div style="background: white; padding: 15px; border-left: 4px solid #667eea; border-radius: 4px;">
              ${contactData.message.replace(/\n/g, '<br>')}
            </div>
          </div>
          
          <div class="section">
            <h3>📊 Technical Details</h3>
            <p><span class="label">Platform:</span><span class="value">${contactData.platform}</span></p>
            <p><span class="label">Message ID:</span><span class="value">${contactData.messageId}</span></p>
            <p><span class="label">Timestamp:</span><span class="value">${contactData.timestamp}</span></p>
            <p><span class="label">IP Address:</span><span class="value">${contactData.ipAddress}</span></p>
          </div>
          
          <div class="section">
            <h3>📱 Device Information</h3>
            <pre class="json-data">${JSON.stringify(contactData.deviceInfo, null, 2)}</pre>
          </div>
          
          <div class="section">
            <h3>🔧 Complete JSON Data</h3>
            <pre class="json-data">${jsonData}</pre>
          </div>
        </div>
        
        <div class="footer">
          <p>📱 Sent from your Flutter Portfolio App | 🕒 ${new Date().toLocaleString()}</p>
          <p>Reply directly to this email to respond to ${contactData.name}</p>
        </div>
      </div>
    </body>
    </html>
  `;
  
  const text = `
New Portfolio Contact Form Submission

Contact Information:
Name: ${contactData.name}
Email: ${contactData.email}
Subject: ${contactData.subject}

Message:
${contactData.message}

Technical Details:
Platform: ${contactData.platform}
Message ID: ${contactData.messageId}
Timestamp: ${contactData.timestamp}
IP Address: ${contactData.ipAddress}

Device Information:
${JSON.stringify(contactData.deviceInfo, null, 2)}

Complete JSON Data:
${jsonData}

---
Sent from your Flutter Portfolio App
${new Date().toLocaleString()}
Reply directly to this email to respond to ${contactData.name}
  `;
  
  return { html, text };
}

// Firestore trigger for automatic email sending
exports.onContactFormSubmit = functions.firestore
  .document('contacts/{contactId}')
  .onCreate(async (snap, context) => {
    try {
      const contactData = snap.data();
      
      // Create email content
      const emailContent = createEmailContent(contactData);
      
      // Send email
      const mailOptions = {
        from: `"Portfolio Contact Form" <${EMAIL_CONFIG.auth.user}>`,
        to: 'rathin007008@gmail.com',
        subject: `Portfolio Contact: ${contactData.subject}`,
        html: emailContent.html,
        text: emailContent.text
      };

      await transporter.sendMail(mailOptions);
      
      console.log('Email sent via Firestore trigger for contact:', context.params.contactId);
      
      // Update document to mark email as sent
      await snap.ref.update({
        emailSent: true,
        emailSentAt: admin.firestore.Timestamp.now()
      });
      
    } catch (error) {
      console.error('Error in Firestore trigger:', error);
      
      // Update document to mark email as failed
      await snap.ref.update({
        emailSent: false,
        emailError: error.message,
        emailAttemptedAt: admin.firestore.Timestamp.now()
      });
    }
  });
