import express from 'express';
import cors from 'cors';
import morgan from 'morgan';
import dotenv from 'dotenv';

import healthRouter from './routes/health.js';
import transactionsRouter from './routes/transactions.js';
import analyticsRouter from './routes/analytics.js';
import categoriesRouter from './routes/categories.js';
import savingsRouter from './routes/savings.js';
import tripsRouter from './routes/trips.js';
import { requireAuth } from './middleware/auth.js';

dotenv.config();

const app = express();
app.use(cors());
app.use(express.json({ limit: '10mb' }));
app.use(express.urlencoded({ extended: true }));
app.use(morgan('dev'));

app.use('/api/v1/health', healthRouter);
app.use('/api/v1/transactions', requireAuth, transactionsRouter);
app.use('/api/v1/analytics', requireAuth, analyticsRouter);
app.use('/api/v1/categories', requireAuth, categoriesRouter);
app.use('/api/v1/savings', requireAuth, savingsRouter);
app.use('/api/v1/trips', requireAuth, tripsRouter);

app.use((req, res) => {
  res.status(404).json({ status: 'error', message: 'Not found' });
});

app.use((err, req, res, next) => {
  console.error('[error]', err);
  res.status(500).json({ status: 'error', message: err.message ?? 'Server error' });
});

const port = process.env.PORT || 4000;
app.listen(port, () => {
  console.log(`NeuralCash backend listening on port ${port}`);
});
