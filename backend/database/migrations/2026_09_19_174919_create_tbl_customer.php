<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Run the migrations.
     */
    public function up(): void
    {
        Schema::create('tbl_customer', function (Blueprint $table) {
            $table->bigIncrements('v_customerId');

            $table->string('v_customerType', 50)->nullable();

            $table->string('v_firstName', 100)->nullable();
            $table->string('v_middleName', 100)->nullable();
            $table->string('v_lastName', 100)->nullable();

            $table->string('v_companyName', 150)->nullable();
            $table->string('v_contactPerson', 150)->nullable();

            $table->string('v_emailAddress', 150)->nullable();
            $table->string('v_mobileNumber', 30)->nullable();
            $table->string('v_telephoneNumber', 30)->nullable();

            $table->string('v_addressLine', 255)->nullable();
            $table->string('v_barangay', 100)->nullable();
            $table->string('v_cityMunicipality', 100)->nullable();
            $table->string('v_province', 100)->nullable();
            $table->string('v_postalCode', 20)->nullable();

            $table->text('v_notes')->nullable();

            $table->boolean('v_isActive')->default(true);

            $table->dateTime('v_createdAt')->useCurrent();
            $table->dateTime('v_updatedAt')->useCurrent();

            $table->index(
                ['v_lastName', 'v_firstName'],
                'idx_customer_name'
            );

            $table->index(
                'v_companyName',
                'idx_customer_companyName'
            );

            $table->index(
                'v_emailAddress',
                'idx_customer_emailAddress'
            );
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('tbl_customer');
    }
};