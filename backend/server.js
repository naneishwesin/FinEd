// backend/server.js
const express = require('express');
const cors = require('cors');
const helmet = require('helmet');
const rateLimit = require('express-rate-limit');
const compression = require('compression');
const morgan = require('morgan');
const { initializeApp } = require('firebase-admin/app');
const { getFirestore } = require('firebase-admin/firestore');
const { getAuth } = require('firebase-admin/auth');
const { credential } = require('firebase-admin');

const app = express();
const PORT = process.env.PORT || 3000;

// Initialize Firebase Admin
const serviceAccount = require('./serviceAccountKey.json');
initializeApp({
  credential: credential.cert(serviceAccount),
});

const db = getFirestore();
const auth = getAuth();

// Middleware
app.use(helmet());
app.use(compression());
app.use(morgan('combined'));
app.use(cors({
  origin: process.env.NODE_ENV === 'production' 
    ? ['https://yourdomain.com'] 
    : ['http://localhost:3000', 'http://localhost:8080'],
  credentials: true,
}));
app.use(express.json({ limit: '10mb' }));
app.use(express.urlencoded({ extended: true, limit: '10mb' }));

// Rate limiting
const limiter = rateLimit({
  windowMs: 15 * 60 * 1000, // 15 minutes
  max: 100, // limit each IP to 100 requests per windowMs
  message: 'Too many requests from this IP, please try again later.',
});
app.use('/api/', limiter);

// Authentication middleware
const authenticateToken = async (req, res, next) => {
  try {
    const authHeader = req.headers.authorization;
    const token = authHeader && authHeader.split(' ')[1];
    
    if (!token) {
      return res.status(401).json({ error: 'Access token required' });
    }
    
    const decodedToken = await auth.verifyIdToken(token);
    req.user = decodedToken;
    next();
  } catch (error) {
    console.error('Authentication error:', error);
    return res.status(403).json({ error: 'Invalid or expired token' });
  }
};

// ==================== HEALTH CHECK ====================
app.get('/health', (req, res) => {
  res.json({ 
    status: 'OK', 
    timestamp: new Date().toISOString(),
    uptime: process.uptime(),
    memory: process.memoryUsage(),
  });
});

// ==================== TRANSACTION ROUTES ====================

// Get all transactions
app.get('/api/transactions', authenticateToken, async (req, res) => {
  try {
    const transactionsRef = db.collection('transactions');
    const snapshot = await transactionsRef
      .where('userId', '==', req.user.uid)
      .orderBy('createdAt', 'desc')
      .get();
    
    const transactions = snapshot.docs.map(doc => ({
      id: doc.id,
      ...doc.data(),
    }));
    
    res.json({ success: true, data: transactions });
  } catch (error) {
    console.error('Error fetching transactions:', error);
    res.status(500).json({ error: 'Failed to fetch transactions' });
  }
});

// Add new transaction
app.post('/api/transactions', authenticateToken, async (req, res) => {
  try {
    const { category, amount, date, time, asset, ledger, remark, type } = req.body;
    
    // Validate required fields
    if (!category || !amount || !date || !time || !asset || !ledger || !type) {
      return res.status(400).json({ error: 'Missing required fields' });
    }
    
    const transactionData = {
      category,
      amount: parseFloat(amount),
      date,
      time,
      asset,
      ledger,
      remark: remark || '',
      type,
      userId: req.user.uid,
      createdAt: new Date(),
      updatedAt: new Date(),
    };
    
    const docRef = await db.collection('transactions').add(transactionData);
    
    // Update user balance
    await updateUserBalance(req.user.uid, parseFloat(amount));
    
    res.json({ 
      success: true, 
      data: { id: docRef.id, ...transactionData },
      message: 'Transaction added successfully' 
    });
  } catch (error) {
    console.error('Error adding transaction:', error);
    res.status(500).json({ error: 'Failed to add transaction' });
  }
});

// Update transaction
app.put('/api/transactions/:id', authenticateToken, async (req, res) => {
  try {
    const { id } = req.params;
    const updateData = { ...req.body, updatedAt: new Date() };
    
    const transactionRef = db.collection('transactions').doc(id);
    const transactionDoc = await transactionRef.get();
    
    if (!transactionDoc.exists) {
      return res.status(404).json({ error: 'Transaction not found' });
    }
    
    if (transactionDoc.data().userId !== req.user.uid) {
      return res.status(403).json({ error: 'Unauthorized' });
    }
    
    await transactionRef.update(updateData);
    
    res.json({ 
      success: true, 
      message: 'Transaction updated successfully' 
    });
  } catch (error) {
    console.error('Error updating transaction:', error);
    res.status(500).json({ error: 'Failed to update transaction' });
  }
});

// Delete transaction
app.delete('/api/transactions/:id', authenticateToken, async (req, res) => {
  try {
    const { id } = req.params;
    
    const transactionRef = db.collection('transactions').doc(id);
    const transactionDoc = await transactionRef.get();
    
    if (!transactionDoc.exists) {
      return res.status(404).json({ error: 'Transaction not found' });
    }
    
    if (transactionDoc.data().userId !== req.user.uid) {
      return res.status(403).json({ error: 'Unauthorized' });
    }
    
    await transactionRef.delete();
    
    res.json({ 
      success: true, 
      message: 'Transaction deleted successfully' 
    });
  } catch (error) {
    console.error('Error deleting transaction:', error);
    res.status(500).json({ error: 'Failed to delete transaction' });
  }
});

// ==================== BALANCE ROUTES ====================

// Get user balances
app.get('/api/balances', authenticateToken, async (req, res) => {
  try {
    const userRef = db.collection('users').doc(req.user.uid);
    const userDoc = await userRef.get();
    
    if (!userDoc.exists) {
      return res.json({ 
        success: true, 
        data: { 
          currentBalance: 0, 
          emergencyBalance: 0, 
          investmentBalance: 0 
        } 
      });
    }
    
    const userData = userDoc.data();
    res.json({ 
      success: true, 
      data: {
        currentBalance: userData.currentBalance || 0,
        emergencyBalance: userData.emergencyBalance || 0,
        investmentBalance: userData.investmentBalance || 0,
      }
    });
  } catch (error) {
    console.error('Error fetching balances:', error);
    res.status(500).json({ error: 'Failed to fetch balances' });
  }
});

// Update balance
app.put('/api/balances/:type', authenticateToken, async (req, res) => {
  try {
    const { type } = req.params;
    const { amount } = req.body;
    
    if (!['current', 'emergency', 'investment'].includes(type)) {
      return res.status(400).json({ error: 'Invalid balance type' });
    }
    
    const userRef = db.collection('users').doc(req.user.uid);
    await userRef.set({
      [`${type}Balance`]: parseFloat(amount),
      lastUpdated: new Date(),
    }, { merge: true });
    
    res.json({ 
      success: true, 
      message: `${type} balance updated successfully` 
    });
  } catch (error) {
    console.error('Error updating balance:', error);
    res.status(500).json({ error: 'Failed to update balance' });
  }
});

// ==================== BUDGET ROUTES ====================

// Get budgets
app.get('/api/budgets', authenticateToken, async (req, res) => {
  try {
    const budgetsRef = db.collection('budgets');
    const snapshot = await budgetsRef
      .where('userId', '==', req.user.uid)
      .orderBy('type')
      .get();
    
    const budgets = snapshot.docs.map(doc => ({
      id: doc.id,
      ...doc.data(),
    }));
    
    res.json({ success: true, data: budgets });
  } catch (error) {
    console.error('Error fetching budgets:', error);
    res.status(500).json({ error: 'Failed to fetch budgets' });
  }
});

// Add/Update budget
app.post('/api/budgets', authenticateToken, async (req, res) => {
  try {
    const { type, amount, spent, category } = req.body;
    
    if (!type || !amount) {
      return res.status(400).json({ error: 'Type and amount are required' });
    }
    
    const budgetData = {
      type,
      amount: parseFloat(amount),
      spent: parseFloat(spent) || 0,
      category: category || null,
      userId: req.user.uid,
      createdAt: new Date(),
      updatedAt: new Date(),
    };
    
    const docRef = await db.collection('budgets').add(budgetData);
    
    res.json({ 
      success: true, 
      data: { id: docRef.id, ...budgetData },
      message: 'Budget created successfully' 
    });
  } catch (error) {
    console.error('Error creating budget:', error);
    res.status(500).json({ error: 'Failed to create budget' });
  }
});

// ==================== ANALYTICS ROUTES ====================

// Get spending analytics
app.get('/api/analytics/spending', authenticateToken, async (req, res) => {
  try {
    const { startDate, endDate } = req.query;
    
    let query = db.collection('transactions')
      .where('userId', '==', req.user.uid)
      .where('type', '==', 'expense');
    
    if (startDate && endDate) {
      query = query
        .where('date', '>=', startDate)
        .where('date', '<=', endDate);
    }
    
    const snapshot = await query.get();
    
    const spendingByCategory = {};
    let totalSpending = 0;
    
    snapshot.docs.forEach(doc => {
      const data = doc.data();
      const category = data.category;
      const amount = Math.abs(data.amount);
      
      spendingByCategory[category] = (spendingByCategory[category] || 0) + amount;
      totalSpending += amount;
    });
    
    res.json({ 
      success: true, 
      data: {
        spendingByCategory,
        totalSpending,
        transactionCount: snapshot.docs.length,
      }
    });
  } catch (error) {
    console.error('Error fetching spending analytics:', error);
    res.status(500).json({ error: 'Failed to fetch spending analytics' });
  }
});

// Get income analytics
app.get('/api/analytics/income', authenticateToken, async (req, res) => {
  try {
    const { startDate, endDate } = req.query;
    
    let query = db.collection('transactions')
      .where('userId', '==', req.user.uid)
      .where('type', '==', 'income');
    
    if (startDate && endDate) {
      query = query
        .where('date', '>=', startDate)
        .where('date', '<=', endDate);
    }
    
    const snapshot = await query.get();
    
    const incomeByCategory = {};
    let totalIncome = 0;
    
    snapshot.docs.forEach(doc => {
      const data = doc.data();
      const category = data.category;
      const amount = data.amount;
      
      incomeByCategory[category] = (incomeByCategory[category] || 0) + amount;
      totalIncome += amount;
    });
    
    res.json({ 
      success: true, 
      data: {
        incomeByCategory,
        totalIncome,
        transactionCount: snapshot.docs.length,
      }
    });
  } catch (error) {
    console.error('Error fetching income analytics:', error);
    res.status(500).json({ error: 'Failed to fetch income analytics' });
  }
});

// ==================== USER ROUTES ====================

// Get user profile
app.get('/api/user/profile', authenticateToken, async (req, res) => {
  try {
    const userRef = db.collection('users').doc(req.user.uid);
    const userDoc = await userRef.get();
    
    if (!userDoc.exists) {
      return res.json({ 
        success: true, 
        data: null 
      });
    }
    
    res.json({ 
      success: true, 
      data: userDoc.data() 
    });
  } catch (error) {
    console.error('Error fetching user profile:', error);
    res.status(500).json({ error: 'Failed to fetch user profile' });
  }
});

// Update user profile
app.put('/api/user/profile', authenticateToken, async (req, res) => {
  try {
    const userRef = db.collection('users').doc(req.user.uid);
    await userRef.set({
      ...req.body,
      lastUpdated: new Date(),
    }, { merge: true });
    
    res.json({ 
      success: true, 
      message: 'Profile updated successfully' 
    });
  } catch (error) {
    console.error('Error updating user profile:', error);
    res.status(500).json({ error: 'Failed to update user profile' });
  }
});

// ==================== UTILITY FUNCTIONS ====================

// Update user balance based on transactions
async function updateUserBalance(userId, amountChange) {
  try {
    const userRef = db.collection('users').doc(userId);
    const userDoc = await userRef.get();
    
    let currentBalance = 0;
    if (userDoc.exists) {
      currentBalance = userDoc.data().currentBalance || 0;
    }
    
    await userRef.set({
      currentBalance: currentBalance + amountChange,
      lastUpdated: new Date(),
    }, { merge: true });
  } catch (error) {
    console.error('Error updating user balance:', error);
  }
}

// ==================== ERROR HANDLING ====================

// 404 handler
app.use('*', (req, res) => {
  res.status(404).json({ error: 'Route not found' });
});

// Global error handler
app.use((error, req, res, next) => {
  console.error('Global error handler:', error);
  res.status(500).json({ 
    error: 'Internal server error',
    message: process.env.NODE_ENV === 'development' ? error.message : 'Something went wrong'
  });
});

// ==================== SERVER START ====================

app.listen(PORT, () => {
  console.log(`🚀 Server running on port ${PORT}`);
  console.log(`📊 Health check: http://localhost:${PORT}/health`);
  console.log(`🔗 API base URL: http://localhost:${PORT}/api`);
});

module.exports = app;
