import inquirer from 'inquirer';
import ora from 'ora';

export async function interact() {
  console.log('🧙‍♂️ Welcome, brave coder! I am Codemancer the Wise.');
  
  while (true) {
    const { question } = await inquirer.prompt([{
      type: 'input',
      name: 'question',
      message: '🔮 Ask your question (or type "exit" to leave):',
    }]);

    if (question.toLowerCase() === 'exit') {
      console.log('✨ May your functions be pure and your algorithms swift!');
      break;
    }

    const spinner = ora('Consulting the ancient tomes...').start();
    
    try {
      // TODO: Implement AI interaction
      await new Promise(resolve => setTimeout(resolve, 1000));
      spinner.succeed('The answer has been revealed!');
      
      console.log(`
        Your question was: "${question}"
        
        I shall implement AI wisdom here soon!
      `);
    } catch (error) {
      spinner.fail('The magical energies failed us!');
      console.error('🌋 Error:', error.message);
    }
  }
}