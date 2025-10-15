// backend/functions/index.js
const functions = require('firebase-functions');
const admin = require('firebase-admin');
const express = require('express');
const cors = require('cors');

// Initialize Firebase Admin
admin.initializeApp();

const app = express();
app.use(cors({ origin: true }));
app.use(express.json());

// ==================== CLOUD FUNCTIONS ====================

// Daily balance recalculation
exports.recalculateBalances = functions.pubsub
  .schedule('0 2 * * *') // Run daily at 2 AM
  .timeZone('Asia/Bangkok')
  .onRun(async (context) => {
    console.log('Starting daily balance recalculation...');
    
    try {
      const db = admin.firestore();
      const usersSnapshot = await db.collection('users').get();
      
      for (const userDoc of usersSnapshot.docs) {
        const userId = userDoc.id;
        
        // Get all transactions for user
        const transactionsSnapshot = await db.collection('transactions')
          .where('userId', '==', userId)
          .get();
        
        let currentBalance = 0;
        let totalIncome = 0;
        let totalExpenses = 0;
        
        transactionsSnapshot.docs.forEach(doc => {
          const data = doc.data();
          const amount = data.amount;
          
          currentBalance += amount;
          
          if (amount > 0) {
            totalIncome += amount;
          } else {
            totalExpenses += Math.abs(amount);
          }
        });
        
        // Update user balances
        await userDoc.ref.update({
          currentBalance,
          totalIncome,
          totalExpenses,
          lastRecalculated: admin.firestore.FieldValue.serverTimestamp(),
        });
        
        console.log(`Updated balances for user ${userId}: ${currentBalance}`);
      }
      
      console.log('Balance recalculation completed successfully');
      return null;
    } catch (error) {
      console.error('Error recalculating balances:', error);
      throw error;
    }
  });

// Budget alert notifications
exports.checkBudgetAlerts = functions.pubsub
  .schedule('0 9 * * *') // Run daily at 9 AM
  .timeZone('Asia/Bangkok')
  .onRun(async (context) => {
    console.log('Checking budget alerts...');
    
    try {
      const db = admin.firestore();
      const budgetsSnapshot = await db.collection('budgets').get();
      
      for (const budgetDoc of budgetsSnapshot.docs) {
        const budget = budgetDoc.data();
        const { userId, type, amount, spent } = budget;
        
        const percentage = (spent / amount) * 100;
        
        // Alert if budget is 80% or more used
        if (percentage >= 80) {
          await db.collection('notifications').add({
            userId,
            type: 'budget_alert',
            title: 'Budget Alert',
            message: `Your ${type} budget is ${percentage.toFixed(1)}% used (${spent}/${amount})`,
            data: {
              budgetType: type,
              percentage,
              amount,
              spent,
            },
            createdAt: admin.firestore.FieldValue.serverTimestamp(),
            read: false,
          });
          
          console.log(`Budget alert sent for user ${userId}, ${type} budget`);
        }
      }
      
      console.log('Budget alerts check completed');
      return null;
    } catch (error) {
      console.error('Error checking budget alerts:', error);
      throw error;
    }
  });

// Financial goal progress notifications
exports.checkGoalProgress = functions.pubsub
  .schedule('0 10 * * 1') // Run weekly on Monday at 10 AM
  .timeZone('Asia/Bangkok')
  .onRun(async (context) => {
    console.log('Checking financial goal progress...');
    
    try {
      const db = admin.firestore();
      const goalsSnapshot = await db.collection('financial_goals').get();
      
      for (const goalDoc of goalsSnapshot.docs) {
        const goal = goalDoc.data();
        const { userId, title, target_amount, current_amount, target_date } = goal;
        
        const progress = (current_amount / target_amount) * 100;
        const daysRemaining = Math.ceil((new Date(target_date) - new Date()) / (1000 * 60 * 60 * 24));
        
        // Alert if goal is behind schedule
        if (daysRemaining > 0 && progress < (daysRemaining / 365) * 100) {
          await db.collection('notifications').add({
            userId,
            type: 'goal_progress',
            title: 'Goal Progress Alert',
            message: `Your goal "${title}" is behind schedule. Current progress: ${progress.toFixed(1)}%`,
            data: {
              goalId: goalDoc.id,
              progress,
              daysRemaining,
              target_amount,
              current_amount,
            },
            createdAt: admin.firestore.FieldValue.serverTimestamp(),
            read: false,
          });
          
          console.log(`Goal progress alert sent for user ${userId}, goal: ${title}`);
        }
      }
      
      console.log('Goal progress check completed');
      return null;
    } catch (error) {
      console.error('Error checking goal progress:', error);
      throw error;
    }
  });

// Transaction analysis and insights
exports.analyzeTransactions = functions.firestore
  .document('transactions/{transactionId}')
  .onCreate(async (snap, context) => {
    const transaction = snap.data();
    const { userId, amount, category, type } = transaction;
    
    try {
      const db = admin.firestore();
      
      // Get user's recent transactions
      const recentTransactionsSnapshot = await db.collection('transactions')
        .where('userId', '==', userId)
        .where('type', '==', type)
        .orderBy('createdAt', 'desc')
        .limit(10)
        .get();
      
      const recentTransactions = recentTransactionsSnapshot.docs.map(doc => doc.data());
      
      // Calculate average spending/income
      const total = recentTransactions.reduce((sum, t) => sum + Math.abs(t.amount), 0);
      const average = total / recentTransactions.length;
      
      // Check for unusual patterns
      const isUnusual = Math.abs(amount) > average * 2;
      
      if (isUnusual) {
        await db.collection('notifications').add({
          userId,
          type: 'unusual_transaction',
          title: 'Unusual Transaction Detected',
          message: `A ${type} of ${Math.abs(amount)} in ${category} seems unusual compared to your average`,
          data: {
            transactionId: context.params.transactionId,
            amount,
            category,
            type,
            average,
          },
          createdAt: admin.firestore.FieldValue.serverTimestamp(),
          read: false,
        });
        
        console.log(`Unusual transaction alert sent for user ${userId}`);
      }
      
      return null;
    } catch (error) {
      console.error('Error analyzing transaction:', error);
      return null;
    }
  });

// User onboarding completion
exports.completeOnboarding = functions.https.onCall(async (data, context) => {
  if (!context.auth) {
    throw new functions.https.HttpsError('unauthenticated', 'User must be authenticated');
  }
  
  try {
    const db = admin.firestore();
    const userId = context.auth.uid;
    
    // Create user document with default settings
    await db.collection('users').doc(userId).set({
      email: context.auth.token.email,
      name: context.auth.token.name || 'User',
      currentBalance: 0,
      emergencyBalance: 0,
      investmentBalance: 0,
      settings: {
        theme: 'light',
        language: 'English',
        currency: 'Thai Baht (฿)',
        monthly_start_date: 1,
        daily_reminder: false,
        spending_alerts: true,
        goal_reminders: false,
        budget_alerts: false,
      },
      onboardingCompleted: true,
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
      lastUpdated: admin.firestore.FieldValue.serverTimestamp(),
    });
    
    // Initialize default categories
    const defaultCategories = [
      { name: '🍕 Food & Dining', icon: '🍕', color: '#FF6B6B', type: 'expense', isDefault: true },
      { name: '🚗 Transportation', icon: '🚗', color: '#4ECDC4', type: 'expense', isDefault: true },
      { name: '🛍️ Shopping', icon: '🛍️', color: '#45B7D1', type: 'expense', isDefault: true },
      { name: '🏠 Housing', icon: '🏠', color: '#96CEB4', type: 'expense', isDefault: true },
      { name: '💼 Salary', icon: '💼', color: '#FFEAA7', type: 'income', isDefault: true },
      { name: '🎁 Allowance', icon: '🎁', color: '#DDA0DD', type: 'income', isDefault: true },
    ];
    
    for (const category of defaultCategories) {
      await db.collection('categories').add({
        ...category,
        userId,
        createdAt: admin.firestore.FieldValue.serverTimestamp(),
      });
    }
    
    return { success: true, message: 'Onboarding completed successfully' };
  } catch (error) {
    console.error('Error completing onboarding:', error);
    throw new functions.https.HttpsError('internal', 'Failed to complete onboarding');
  }
});

// Export data for user
exports.exportUserData = functions.https.onCall(async (data, context) => {
  if (!context.auth) {
    throw new functions.https.HttpsError('unauthenticated', 'User must be authenticated');
  }
  
  try {
    const db = admin.firestore();
    const userId = context.auth.uid;
    
    // Collect all user data
    const userData = {
      user: (await db.collection('users').doc(userId).get()).data(),
      transactions: (await db.collection('transactions').where('userId', '==', userId).get()).docs.map(doc => ({ id: doc.id, ...doc.data() })),
      budgets: (await db.collection('budgets').where('userId', '==', userId).get()).docs.map(doc => ({ id: doc.id, ...doc.data() })),
      assets: (await db.collection('assets').where('userId', '==', userId).get()).docs.map(doc => ({ id: doc.id, ...doc.data() })),
      liabilities: (await db.collection('liabilities').where('userId', '==', userId).get()).docs.map(doc => ({ id: doc.id, ...doc.data() })),
      goals: (await db.collection('financial_goals').where('userId', '==', userId).get()).docs.map(doc => ({ id: doc.id, ...doc.data() })),
      investments: (await db.collection('investments').where('userId', '==', userId).get()).docs.map(doc => ({ id: doc.id, ...doc.data() })),
      emergencyFunds: (await db.collection('emergency_funds').where('userId', '==', userId).get()).docs.map(doc => ({ id: doc.id, ...doc.data() })),
      exportDate: new Date().toISOString(),
    };
    
    return { success: true, data: userData };
  } catch (error) {
    console.error('Error exporting user data:', error);
    throw new functions.https.HttpsError('internal', 'Failed to export user data');
  }
});

// Clean up old notifications
exports.cleanupNotifications = functions.pubsub
  .schedule('0 3 * * 0') // Run weekly on Sunday at 3 AM
  .timeZone('Asia/Bangkok')
  .onRun(async (context) => {
    console.log('Cleaning up old notifications...');
    
    try {
      const db = admin.firestore();
      const thirtyDaysAgo = new Date();
      thirtyDaysAgo.setDate(thirtyDaysAgo.getDate() - 30);
      
      const oldNotificationsSnapshot = await db.collection('notifications')
        .where('createdAt', '<', thirtyDaysAgo)
        .get();
      
      const batch = db.batch();
      oldNotificationsSnapshot.docs.forEach(doc => {
        batch.delete(doc.ref);
      });
      
      await batch.commit();
      
      console.log(`Cleaned up ${oldNotificationsSnapshot.docs.length} old notifications`);
      return null;
    } catch (error) {
      console.error('Error cleaning up notifications:', error);
      throw error;
    }
  });

// HTTP API endpoints
app.get('/health', (req, res) => {
  res.json({ 
    status: 'OK', 
    timestamp: new Date().toISOString(),
    service: 'Firebase Cloud Functions'
  });
});

// Export the Express app as a Cloud Function
exports.api = functions.https.onRequest(app);
