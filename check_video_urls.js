// Check full video URLs
const { createClient } = require('@supabase/supabase-js');
require('dotenv').config();

const supabase = createClient(
  process.env.EXPO_PUBLIC_SUPABASE_URL,
  process.env.EXPO_PUBLIC_SUPABASE_ANON_KEY
);

async function checkVideoUrls() {
  console.log('🔍 Checking hero video URLs...\n');
  
  try {
    const { data, error } = await supabase
      .from('hero_media')
      .select('*')
      .eq('is_active', true)
      .order('position', { ascending: true });

    if (error) {
      console.error('❌ Error:', error.message);
      return;
    }

    if (!data || data.length === 0) {
      console.log('⚠️  No active hero media found');
      return;
    }

    console.log(`✅ Found ${data.length} active hero media items:\n`);
    
    data.forEach((item, index) => {
      console.log(`📍 Slide ${index + 1}:`);
      console.log(`   Type: ${item.type}`);
      console.log(`   Position: ${item.position}`);
      console.log(`   Full URI: ${item.uri}`);
      console.log(`   Is Active: ${item.is_active}`);
      console.log('');
    });
    
  } catch (err) {
    console.error('❌ Exception:', err.message);
  }
}

checkVideoUrls();
