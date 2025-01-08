#!/usr/bin/env node
import { program } from 'commander';
import { config } from 'dotenv';
import { interact } from './commands/interact.js';

// Load environment variables
config();

program
  .name('cryptex')
  .description('A magical CLI for code generation and assistance')
  .version('1.0.0');

program
  .command('interact')
  .description('Start an interactive session with Codemancer')
  .action(interact);

program.parse();