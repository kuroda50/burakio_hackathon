require('dotenv').config();

const { OpenAI } = require('openai');
const openai = new OpenAI({
    apiKey: process.env.OPENAI_API_KEY,  // ここに自分のAPIキーを入力
});

async function testOpenAI() {
    try {
        const response = await openai.chat.completions.create({
            model: 'gpt-4',  // または 'gpt-3.5-turbo'
            messages: [{ role: 'user', content: 'Hello, OpenAI!' }],
        });
        console.log('OpenAI Response:', response);
        console.log('AIのメッセージ:', response.choices[0].message.content);
    } catch (error) {
        console.error('Error:', error);
    }
}

testOpenAI();
