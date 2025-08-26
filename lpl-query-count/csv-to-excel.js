const fs = require('fs');
const path = require('path');
const XLSX = require('xlsx');

/**
 * Node.js script to convert CSV performance data to Excel format
 * Parses the semicolon-separated format and creates a clean Excel file
 */

function parseCSVLine(line) {
    if (!line.trim()) return null;

    // Split by semicolon to get the three parts
    const parts = line.split(';');
    if (parts.length < 3) return null;

    // Extract number (first part)
    const number = parts[0].trim();

    // Extract description (second part, remove desc=" and closing quote)
    const descMatch = parts[1].match(/desc="(.+)"/);
    const description = descMatch ? descMatch[1] : parts[1].replace('desc=', '').replace(/"/g, '');

    // Extract duration (third part, remove dur=)
    const duration = parts[2].replace('dur=', '').trim();

    return {
        number: number,
        description: description,
        duration: parseFloat(duration)
    };
}

function convertCSVToExcel(inputFilePath, outputFilePath) {
    try {
        console.log(`Reading CSV file: ${inputFilePath}`);

        // Read the CSV file
        const csvContent = fs.readFileSync(inputFilePath, 'utf8');
        const lines = csvContent.split('\n');

        // Parse each line and collect valid data
        const data = [];
        lines.forEach((line, index) => {
            const parsed = parseCSVLine(line);
            if (parsed) {
                data.push(parsed);
            }
        });

        console.log(`Parsed ${data.length} records`);

        // Create a new workbook
        const workbook = XLSX.utils.book_new();

        // Convert data to worksheet format
        const worksheet = XLSX.utils.json_to_sheet(data);

        // Set column widths for better readability
        const columnWidths = [
            { wch: 10 }, // Number column
            { wch: 80 }, // Description column (wider for SQL queries)
            { wch: 15 }  // Duration column
        ];
        worksheet['!cols'] = columnWidths;

        // Add the worksheet to the workbook
        XLSX.utils.book_append_sheet(workbook, worksheet, 'Performance Data');

        // Write the Excel file
        XLSX.writeFile(workbook, outputFilePath);

        console.log(`Excel file created successfully: ${outputFilePath}`);
        console.log(`Columns: Number, Description, Duration`);
        console.log(`Total records: ${data.length}`);

        // Display sample data
        if (data.length > 0) {
            console.log('\nSample data:');
            console.log('Number | Duration | Description (truncated)');
            console.log('-------|----------|----------------------');
            data.slice(0, 3).forEach(row => {
                const truncatedDesc = row.description.length > 50
                    ? row.description.substring(0, 50) + '...'
                    : row.description;
                console.log(`${row.number.padEnd(6)} | ${row.duration.toString().padEnd(8)} | ${truncatedDesc}`);
            });
        }

    } catch (error) {
        console.error('Error converting CSV to Excel:', error.message);
        process.exit(1);
    }
}

// Main execution
function main() {
    const args = process.argv.slice(2);

    if (args.length === 0) {
        console.log('Usage: node csv-to-excel.js <input-csv-file> [output-excel-file]');
        console.log('');
        console.log('Examples:');
        console.log('  node csv-to-excel.js data.csv');
        console.log('  node csv-to-excel.js data.csv output.xlsx');
        console.log('');
        console.log('If no output file is specified, it will use the input filename with .xlsx extension');
        process.exit(1);
    }

    const inputFile = args[0];
    const outputFile = args[1] || inputFile.replace(/\.csv$/i, '.xlsx');

    // Check if input file exists
    if (!fs.existsSync(inputFile)) {
        console.error(`Error: Input file '${inputFile}' does not exist`);
        process.exit(1);
    }

    convertCSVToExcel(inputFile, outputFile);
}

// Run the script
if (require.main === module) {
    main();
}

module.exports = { convertCSVToExcel, parseCSVLine };
